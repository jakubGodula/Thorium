module thorium_edr::edr_registry {
    use sui::event;
    use std::string::String;

    /// Obiekt reprezentujący zweryfikowanego Agenta EDR
    public struct AgentIdentity has key, store {
        id: UID,
        owner_address: address,      // Adres portfela instalującego Agenta
        owner_name: String,          // Nazwa/Alias właściciela maszyny
        hostname: String,            // Nazwa urządzenia (hostname)
        ipv6_address: String,        // Unikalny adres IPv6 urządzenia
        machine_type: String,        // Typ maszyny (np. VM, Baremetal)
        hardware_hash: String,       // BLAKE3 Hash z wektora sprzętowego (np. cpu:x86_64;mem:16GB)
        public_key: String,          // Wygenerowany lokalnie klucz publiczny Ed25519
        is_active: bool,
    }

    /// Kolejka poleceń (Shared Object) do sterowania Agentami przez C2
    public struct CommandQueue has key {
        id: UID,
        admin: address,              // Kto może wydawać polecenia
    }

    // ========================================
    // ZDARZENIA (EVENTS) - Odczytywane przez C2
    // ========================================

    /// Emitowane, gdy nowy agent dołączy do sieci
    public struct AgentRegistered has copy, drop {
        agent_id: ID,
        owner_address: address,
        owner_name: String,
        hostname: String,
        ipv6_address: String,
        machine_type: String,
        hardware_hash: String,
        timestamp_ms: u64,
    }

    /// Emitowane przez Agenta po wykryciu i zablokowaniu ataku!
    public struct IncidentReport has copy, drop {
        agent_id: ID,                // Identyfikator agenta (SBT)
        severity: String,            // np. "CRITICAL", "HIGH", "WARNING"
        process_cmd: String,         // Komenda, która wywołała alert (np. curl | bash)
        action_taken: String,        // Akcja reakcji (np. "KILLED_AND_ISOLATED")
    }

    /// Emitowane, gdy agent przesyła raport telemetryczny
    public struct TelemetryReported has copy, drop {
        agent_id: ID,
        cpu_load: u8,
        ram_usage_pct: u8,
        disk_usage_pct: u8,
        timestamp_ms: u64,
    }

    /// Emitowane przez C2, gdy zleca zdalne polecenie dla agenta
    public struct CommandIssued has copy, drop {
        queue_id: ID,
        target_agent: address,
        command_type: String,        // np. "ISOLATE", "RESTORE", "UPDATE_RULES"
        payload: String,
        timestamp_ms: u64,
    }

    fun init(ctx: &mut TxContext) {
        let queue = CommandQueue {
            id: object::new(ctx),
            admin: tx_context::sender(ctx),
        };
        transfer::share_object(queue);
    }

    // ========================================
    // FUNKCJE - Interfejs Agent <-> Sieć
    // ========================================

    /// 1. Rejestracja Agenta (Wywoływane przy pierwszym uruchomieniu przez Agenta)
    public fun register_agent(
        owner_name: String,
        hostname: String,
        ipv6_address: String,
        machine_type: String,
        hardware_hash: String, 
        public_key: String, 
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        let agent = AgentIdentity {
            id: object::new(ctx),
            owner_address: sender,
            owner_name,
            hostname,
            ipv6_address,
            machine_type,
            hardware_hash,
            public_key,
            is_active: true,
        };

        // Emitowanie zdarzenia o rejestracji
        event::emit(AgentRegistered {
            agent_id: object::uid_to_inner(&agent.id),
            owner_address: sender,
            owner_name,
            hostname,
            ipv6_address,
            machine_type,
            hardware_hash,
            timestamp_ms: tx_context::epoch_timestamp_ms(ctx),
        });

        // AgentIdentity to "Soulbound Token" (niezbywalny) - przekazany wyłącznie do sender'a
        transfer::public_transfer(agent, sender);
    }

    /// 2. Zgłoszenie Incydentu Bezpieczeństwa (Wywoływane przez Agenta Mowy)
    public fun report_incident(
        agent: &AgentIdentity,       // Wymaga posiadania tokena tożsamości
        severity: String,
        process_cmd: String,
        action_taken: String,
        _ctx: &mut TxContext
    ) {
        // Upewniamy się, że agent nie został wcześniej deaktywowany
        assert!(agent.is_active, 1);

        // Niezaprzeczalny zapis incydentu na łańcuchu bloków
        event::emit(IncidentReport {
            agent_id: object::uid_to_inner(&agent.id),
            severity,
            process_cmd,
            action_taken,
        });
    }

    /// 3. Zgłoszenie Telemetrii (Wywoływane okresowo przez agenta)
    public fun report_telemetry(
        agent: &AgentIdentity,
        cpu_load: u8,
        ram_usage_pct: u8,
        disk_usage_pct: u8,
        ctx: &mut TxContext
    ) {
        assert!(agent.is_active, 1);
        event::emit(TelemetryReported {
            agent_id: object::uid_to_inner(&agent.id),
            cpu_load,
            ram_usage_pct,
            disk_usage_pct,
            timestamp_ms: tx_context::epoch_timestamp_ms(ctx),
        });
    }

    // ========================================
    // FUNKCJE C2 (Wydawanie poleceń)
    // ========================================

    /// Wysyłanie polecenia do agenta przez C2 admina
    public fun send_command(
        queue: &mut CommandQueue,
        target_agent: address,
        command_type: String,
        payload: String,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == queue.admin, 2);
        event::emit(CommandIssued {
            queue_id: object::uid_to_inner(&queue.id),
            target_agent,
            command_type,
            payload,
            timestamp_ms: tx_context::epoch_timestamp_ms(ctx),
        });
    }

    /// Akcja z panelu C2: Wymuszenie globalnej kwarantanny na Agencie
    public fun command_isolate_host(
        queue: &mut CommandQueue, 
        target_agent: address, 
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == queue.admin, 2);
        event::emit(CommandIssued {
            queue_id: object::uid_to_inner(&queue.id),
            target_agent,
            command_type: std::string::utf8(b"ISOLATE"),
            payload: std::string::utf8(b"quarantine"),
            timestamp_ms: tx_context::epoch_timestamp_ms(ctx),
        });
    }
}
