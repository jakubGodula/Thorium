module thorium_edr::edr_registry {
    use sui::event;
    use std::string::String;
    use sui::vec_map::{Self, VecMap};

    // ========================================
    // STRUKTURY DANYCH
    // ========================================

    /// Polityka bezpieczeństwa (Polonium) dla danej Organizacji
    public struct SecurityPolicy has store {
        allowed_processes: vector<String>,
        blocked_processes: vector<String>,
        blocked_ips: vector<String>,
        fim_monitored_paths: vector<String>,
        active_playbooks: vector<String>,
        risk_level_threshold: u64,
        rule_weights: VecMap<String, u64>,
    }

    /// Organizacja - główny obiekt zarządzający flotą i uprawnieniami (Shared Object)
    public struct Organization has key {
        id: UID,
        name: String,
        owner: address,
        admin_roles: VecMap<address, vector<String>>, // Adres -> Lista Ról (np. "POLICY_ADMIN", "OPERATOR")
        committee_thresholds: VecMap<String, u64>,    // Nazwa Roli -> Wymagana ilość podpisów

        policy: SecurityPolicy,
        owner_last_active_ms: u64,                    // Czas ostatniej aktywności właściciela (Hit by a bus)
        dead_man_switch_days: u64,                    // Ilość dni po których można awaryjnie przejąć własność (0 = wyłączone)
    }

    /// Agent powiązany z konkretną organizacją (Soulbound Token dla portfela maszyny)
    public struct AgentIdentity has key, store {
        id: UID,
        org_id: ID,                  // Powiązanie z organizacją
        owner_name: String,
        hostname: String,
        ipv6_address: String,
        machine_type: String,
        hardware_hash: String,
        public_key: String,
        is_active: bool,
    }

    /// Propozycja akcji Multi-Sig oczekująca na głosy komitetu (Shared Object)
    public struct ActionProposal has key, store {
        id: UID,
        org_id: ID,
        proposer: address,
        action_type: String,         // np. "ISOLATE_HOST", "UPDATE_POLICY", "REMOVE_ADMIN"
        target_admin: address,       // Cel do usunięcia uprawnień (jeśli dotyczy)
        payload_1: String,           // Generyczne pola payloadu zależne od akcji
        payload_2: String,
        approvals: vector<address>,  // Lista adresów z komitetu, które złożyły podpis
        executed: bool,
    }

    // ========================================
    // ZDARZENIA (EVENTS)
    // ========================================

    public struct OrganizationCreated has copy, drop {
        org_id: ID,
        name: String,
        owner: address,
    }

    public struct AgentRegistered has copy, drop {
        agent_id: ID,
        org_id: ID,
        hostname: String,
        ipv6_address: String,
        timestamp_ms: u64,
    }

    public struct IncidentReport has copy, drop {
        agent_id: ID,
        org_id: ID,
        severity: String,
        process_cmd: String,
        action_taken: String,
    }

    public struct TelemetryReported has copy, drop {
        agent_id: ID,
        org_id: ID,
        cpu_load: u8,
        ram_usage_pct: u8,
        disk_usage_pct: u8,
        timestamp_ms: u64,
    }

    public struct CommandIssued has copy, drop {
        org_id: ID,
        target_agent: address, 
        command_type: String,
        payload: String,
        timestamp_ms: u64,
    }

    public struct PolicyUpdated has copy, drop {
        org_id: ID,
        timestamp_ms: u64,
    }

    // ========================================
    // INICJALIZACJA I ZARZĄDZANIE ORGANIZACJĄ
    // ========================================

    fun init(_ctx: &mut TxContext) {
        // Kontrakt nie tworzy już globalnej kolejki. Administratorzy tworzą Organizacje dynamicznie.
    }

    /// Tworzenie nowej organizacji przez głównego właściciela (Ownera)
    public fun create_organization(name: String, default_threshold: u64, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let mut admin_roles = vec_map::empty();
        
        // Owner dostaje wszystkie role komitetów z automatu
        let mut owner_roles = vector::empty<String>();
        vector::push_back(&mut owner_roles, std::string::utf8(b"OWNER"));
        vector::push_back(&mut owner_roles, std::string::utf8(b"OPERATOR"));
        vector::push_back(&mut owner_roles, std::string::utf8(b"POLICY_ADMIN"));
        vector::push_back(&mut owner_roles, std::string::utf8(b"ADMIN_COMMITTEE"));
        vec_map::insert(&mut admin_roles, sender, owner_roles);

        let mut committee_thresholds = vec_map::empty();
        vec_map::insert(&mut committee_thresholds, std::string::utf8(b"OPERATOR"), default_threshold);
        vec_map::insert(&mut committee_thresholds, std::string::utf8(b"POLICY_ADMIN"), default_threshold);
        vec_map::insert(&mut committee_thresholds, std::string::utf8(b"ADMIN_COMMITTEE"), default_threshold);

        let mut rule_weights = vec_map::empty();
        vec_map::insert(&mut rule_weights, std::string::utf8(b"BASH_SHELL"), 20);
        vec_map::insert(&mut rule_weights, std::string::utf8(b"NETWORK_CURL"), 30);
        vec_map::insert(&mut rule_weights, std::string::utf8(b"FILE_CHMOD"), 25);
        vec_map::insert(&mut rule_weights, std::string::utf8(b"OUTBOUND_CONN"), 40);
        vec_map::insert(&mut rule_weights, std::string::utf8(b"FIM_MODIFICATION"), 30);

        let policy = SecurityPolicy {
            allowed_processes: vector::empty(),
            blocked_processes: vector::empty(),
            blocked_ips: vector::empty(),
            fim_monitored_paths: vector::empty(),
            active_playbooks: vector::empty(),
            risk_level_threshold: 85,
            rule_weights,
        };

        let org = Organization {
            id: object::new(ctx),
            name,
            owner: sender,
            admin_roles,
            committee_thresholds,
            policy,

            owner_last_active_ms: tx_context::epoch_timestamp_ms(ctx),
            dead_man_switch_days: 0,
        };

        event::emit(OrganizationCreated {
            org_id: object::uid_to_inner(&org.id),
            name: org.name,
            owner: sender,
        });

        transfer::share_object(org);
    }

    /// Dodawanie/modyfikacja administratora przez Ownera organizacji
    public fun set_admin_role(
        org: &mut Organization,
        admin_address: address,
        roles: vector<String>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        // Tylko główny właściciel (OWNER) może zarządzać komitetem i uprawnieniami
        assert!(sender == org.owner, 1);
        
        if (vec_map::contains(&org.admin_roles, &admin_address)) {
            let existing_roles = vec_map::get_mut(&mut org.admin_roles, &admin_address);
            *existing_roles = roles;
        } else {
            vec_map::insert(&mut org.admin_roles, admin_address, roles);
        }
    }

    /// Przekazanie głównej własności organizacji innemu adresowi
    public fun transfer_ownership(
        org: &mut Organization,
        new_owner: address,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(sender == org.owner, 8); // Tylko obecny właściciel może oddać organizację

        org.owner = new_owner;

        // Nadaj nowemu właścicielowi wszystkie role
        let mut owner_roles = vector::empty<String>();
        vector::push_back(&mut owner_roles, std::string::utf8(b"OWNER"));
        vector::push_back(&mut owner_roles, std::string::utf8(b"OPERATOR"));
        vector::push_back(&mut owner_roles, std::string::utf8(b"POLICY_ADMIN"));
        vector::push_back(&mut owner_roles, std::string::utf8(b"ADMIN_COMMITTEE"));
        
        if (vec_map::contains(&org.admin_roles, &new_owner)) {
            let existing_roles = vec_map::get_mut(&mut org.admin_roles, &new_owner);
            *existing_roles = owner_roles;
        } else {
            vec_map::insert(&mut org.admin_roles, new_owner, owner_roles);
        };

        // Odbierz dawnemu właścicielowi (sender) wszystkie role administracyjne, aby uniknąć konfliktów
        if (vec_map::contains(&org.admin_roles, &sender)) {
            let (_, _) = vec_map::remove(&mut org.admin_roles, &sender);
        };
    }

    /// Modyfikacja progu podpisów dla konkretnego komitetu (np. "OPERATOR")
    public fun set_committee_threshold(org: &mut Organization, role: String, threshold: u64, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == org.owner, 1);
        if (vec_map::contains(&org.committee_thresholds, &role)) {
            let val = vec_map::get_mut(&mut org.committee_thresholds, &role);
            *val = threshold;
        } else {
            vec_map::insert(&mut org.committee_thresholds, role, threshold);
        }
    }

    /// Ustawienie progu punktacji dla incydentów XDR
    public fun set_risk_threshold(org: &mut Organization, threshold: u64, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(sender == org.owner || has_role(org, sender, std::string::utf8(b"POLICY_ADMIN")), 1);
        org.policy.risk_level_threshold = threshold;
    }

    /// Modyfikacja punktacji konkretnej reguły behawioralnej
    public fun set_rule_weight(org: &mut Organization, rule_name: String, weight: u64, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(sender == org.owner || has_role(org, sender, std::string::utf8(b"POLICY_ADMIN")), 1);
        if (vec_map::contains(&org.policy.rule_weights, &rule_name)) {
            let val = vec_map::get_mut(&mut org.policy.rule_weights, &rule_name);
            *val = weight;
        } else {
            vec_map::insert(&mut org.policy.rule_weights, rule_name, weight);
        }
    }

    /// Właściciel zgłasza aktywność, co resetuje licznik "Hit by a bus"
    public fun ping_active(org: &mut Organization, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == org.owner, 1);
        org.owner_last_active_ms = tx_context::epoch_timestamp_ms(ctx);
    }

    /// Ustawienie czasu (w dniach) po jakim następuje aktywacja "Hit by a bus" (0 = wyłączone)
    public fun set_dead_man_switch(org: &mut Organization, days: u64, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == org.owner, 1);
        org.dead_man_switch_days = days;
        org.owner_last_active_ms = tx_context::epoch_timestamp_ms(ctx);
    }

    // ========================================
    // REJESTRACJA I RAPORTOWANIE Z AGENTA
    // ========================================

    public fun register_agent(
        org: &Organization,
        owner_name: String,
        hostname: String,
        ipv6_address: String,
        machine_type: String,
        hardware_hash: String, 
        public_key: String, 
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let org_id = object::uid_to_inner(&org.id);
        
        let agent = AgentIdentity {
            id: object::new(ctx),
            org_id,
            owner_name,
            hostname,
            ipv6_address,
            machine_type,
            hardware_hash,
            public_key,
            is_active: true,
        };

        event::emit(AgentRegistered {
            agent_id: object::uid_to_inner(&agent.id),
            org_id,
            hostname,
            ipv6_address,
            timestamp_ms: tx_context::epoch_timestamp_ms(ctx),
        });

        // Właściwy token tożsamości trafia do portfela Agenta
        transfer::public_transfer(agent, sender);
    }

    public fun report_incident(
        agent: &AgentIdentity,
        severity: String,
        process_cmd: String,
        action_taken: String,
        _ctx: &mut TxContext
    ) {
        assert!(agent.is_active, 2);
        event::emit(IncidentReport {
            agent_id: object::uid_to_inner(&agent.id),
            org_id: agent.org_id,
            severity,
            process_cmd,
            action_taken,
        });
    }

    // ========================================
    // MULTI-SIG PROPOSALS & ROLES (SOAR / POLONIUM)
    // ========================================

    /// Funkcja pomocnicza sprawdzająca posiadanie określonej roli przez podany adres
    fun has_role(org: &Organization, user: address, required_role: String): bool {
        if (user == org.owner) { return true; } // Właściciel dziedziczy wszystkie role
        if (!vec_map::contains(&org.admin_roles, &user)) { return false; }
        
        let roles = vec_map::get(&org.admin_roles, &user);
        let mut i = 0;
        let len = vector::length(roles);
        while (i < len) {
            let r = vector::borrow(roles, i);
            if (r == &required_role) { return true; }
            i = i + 1;
        };
        false
    }

    /// Złożenie propozycji akcji krytycznej w ramach organizacji
    public fun propose_action(
        org: &Organization,
        action_type: String,
        target_admin: address,
        payload_1: String,
        payload_2: String,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        // Dynamiczna weryfikacja uprawnień (RBAC) w zależności od akcji
        let is_valid = if (action_type == std::string::utf8(b"ISOLATE_HOST")) {
            has_role(org, sender, std::string::utf8(b"OPERATOR"))
        } else if (action_type == std::string::utf8(b"UPDATE_POLICY")) {
            has_role(org, sender, std::string::utf8(b"POLICY_ADMIN"))
        } else if (action_type == std::string::utf8(b"REMOVE_ADMIN")) {
            has_role(org, sender, std::string::utf8(b"ADMIN_COMMITTEE"))
        } else if (action_type == std::string::utf8(b"EMERGENCY_TRANSFER")) {
            let current_time = tx_context::epoch_timestamp_ms(ctx);
            let time_since_active = current_time - org.owner_last_active_ms;
            let timeout_ms = org.dead_man_switch_days * 24 * 60 * 60 * 1000;
            
            assert!(org.dead_man_switch_days > 0, 9); // Błąd 9: Mechanizm "Hit by a bus" wyłączony
            assert!(time_since_active > timeout_ms, 10); // Błąd 10: Czas jeszcze nie minął
            
            has_role(org, sender, std::string::utf8(b"ADMIN_COMMITTEE"))
        } else {
            false
        };
        assert!(is_valid, 3); // Błąd 3: Brak uprawnień do zaproponowania akcji

        let mut approvals = vector::empty<address>();
        vector::push_back(&mut approvals, sender); // Proponujący od razu daje swój pierwszy podpis

        let proposal = ActionProposal {
            id: object::new(ctx),
            org_id: object::uid_to_inner(&org.id),
            proposer: sender,
            action_type,
            target_admin,
            payload_1,
            payload_2,
            approvals,
            executed: false,
        };
        
        transfer::share_object(proposal);
    }

    /// Zatwierdzanie propozycji i jej ewentualne wykonanie (jeśli próg został osiągnięty)
    public fun approve_action(
        org: &mut Organization,
        proposal: &mut ActionProposal,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        assert!(!proposal.executed, 4); // Błąd 4: Akcja została już wcześniej wykonana
        assert!(proposal.org_id == object::uid_to_inner(&org.id), 5); // Błąd 5: Propozycja nie należy do tej organizacji
        
        // Identyczna weryfikacja uprawnień co przy propzycji - by zatwierdzić, musisz mieć prawa
        let is_valid = if (proposal.action_type == std::string::utf8(b"ISOLATE_HOST")) {
            has_role(org, sender, std::string::utf8(b"OPERATOR"))
        } else if (proposal.action_type == std::string::utf8(b"UPDATE_POLICY")) {
            has_role(org, sender, std::string::utf8(b"POLICY_ADMIN"))
        } else if (proposal.action_type == std::string::utf8(b"REMOVE_ADMIN")) {
            has_role(org, sender, std::string::utf8(b"ADMIN_COMMITTEE"))
        } else if (proposal.action_type == std::string::utf8(b"EMERGENCY_TRANSFER")) {
            let current_time = tx_context::epoch_timestamp_ms(ctx);
            let time_since_active = current_time - org.owner_last_active_ms;
            let timeout_ms = org.dead_man_switch_days * 24 * 60 * 60 * 1000;
            
            assert!(org.dead_man_switch_days > 0, 9);
            assert!(time_since_active > timeout_ms, 10);

            has_role(org, sender, std::string::utf8(b"ADMIN_COMMITTEE"))
        } else {
            false
        };
        assert!(is_valid, 6); // Błąd 6: Brak uprawnień do zatwierdzania tej klasy akcji

        // Ochrona przed podwójnym głosowaniem z tego samego klucza
        let mut i = 0;
        let len = vector::length(&proposal.approvals);
        let mut already_voted = false;
        while (i < len) {
            if (vector::borrow(&proposal.approvals, i) == &sender) {
                already_voted = true;
                break;
            };
            i = i + 1;
        };
        assert!(!already_voted, 7); // Błąd 7: Administrator już oddał podpis pod tą propozycją

        // Złożenie podpisu
        vector::push_back(&mut proposal.approvals, sender);

        let required_role_for_threshold = if (proposal.action_type == std::string::utf8(b"ISOLATE_HOST")) {
            std::string::utf8(b"OPERATOR")
        } else if (proposal.action_type == std::string::utf8(b"UPDATE_POLICY")) {
            std::string::utf8(b"POLICY_ADMIN")
        } else {
            std::string::utf8(b"ADMIN_COMMITTEE")
        };

        let threshold = if (vec_map::contains(&org.committee_thresholds, &required_role_for_threshold)) {
            *vec_map::get(&org.committee_thresholds, &required_role_for_threshold)
        } else {
            1
        };

        // Automatyczne wykonanie akcji natychmiast po osiągnięciu wymaganego progu N-z-M
        if (vector::length(&proposal.approvals) >= threshold) {
            proposal.executed = true;

            if (proposal.action_type == std::string::utf8(b"ISOLATE_HOST")) {
                event::emit(CommandIssued {
                    org_id: object::uid_to_inner(&org.id),
                    target_agent: @0x0, // Zastąpione w UI odpowiednim adresem agenta podawanym w payloadzie
                    command_type: std::string::utf8(b"ISOLATE"),
                    payload: proposal.payload_1,
                    timestamp_ms: tx_context::epoch_timestamp_ms(ctx),
                });
            } else if (proposal.action_type == std::string::utf8(b"UPDATE_POLICY")) {
                // Skutek wejścia w życie reguły Polonium - C2 wysyła do sieci event
                event::emit(PolicyUpdated {
                    org_id: object::uid_to_inner(&org.id),
                    timestamp_ms: tx_context::epoch_timestamp_ms(ctx),
                });
            } else if (proposal.action_type == std::string::utf8(b"REMOVE_ADMIN")) {
                // Skutek przegłosowania pozbawienia administratora wszystkich jego ról
                if (vec_map::contains(&org.admin_roles, &proposal.target_admin)) {
                    let (_, _) = vec_map::remove(&mut org.admin_roles, &proposal.target_admin);
                };
            } else if (proposal.action_type == std::string::utf8(b"EMERGENCY_TRANSFER")) {
                // Scenariusz Hit by a bus: Admin Committee przejmuje awaryjnie organizację i przekazuje nowemu właścicielowi
                let old_owner = org.owner;
                let new_owner = proposal.target_admin;
                
                org.owner = new_owner;
                
                // Nadanie praw OWNER nowemu właścicielowi (wszystkie role)
                let mut owner_roles = vector::empty<String>();
                vector::push_back(&mut owner_roles, std::string::utf8(b"OWNER"));
                vector::push_back(&mut owner_roles, std::string::utf8(b"OPERATOR"));
                vector::push_back(&mut owner_roles, std::string::utf8(b"POLICY_ADMIN"));
                vector::push_back(&mut owner_roles, std::string::utf8(b"ADMIN_COMMITTEE"));
                if (vec_map::contains(&org.admin_roles, &new_owner)) {
                    let existing_roles = vec_map::get_mut(&mut org.admin_roles, &new_owner);
                    *existing_roles = owner_roles;
                } else {
                    vec_map::insert(&mut org.admin_roles, new_owner, owner_roles);
                };

                // Usunięcie praw starego (utraconego) właściciela
                if (vec_map::contains(&org.admin_roles, &old_owner)) {
                    let (_, _) = vec_map::remove(&mut org.admin_roles, &old_owner);
                };
            };
        }
    }
}
