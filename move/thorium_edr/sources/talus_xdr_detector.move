module thorium_edr::talus_xdr_detector {
    use sui::event;
    use std::string::String;
    use sui::table::{Self, Table};
    use sui::ed25519;

    // Error codes
    const EINVALID_SIGNATURE: u64 = 301;
    const EMODEL_INACTIVE: u64 = 302;
    const EUNAUTHORIZED_MODEL: u64 = 303;
    const ENOT_ADMIN: u64 = 304;

    /// Configuration parameters for AI detection
    public struct DetectionPolicy has key {
        id: UID,
        admin: address,
        anomaly_threshold: u8,              // e.g. 85 (representing 85% probability)
        authorized_ai_agents: Table<address, bool>, // Approved off-chain AI keys
    }

    /// Event emitted when a verified AI agent reports a classification
    public struct ClassificationReported has copy, drop {
        agent_id: address,
        telemetry_hash: String,
        anomaly_score: u8,
        classification: String,
        action_taken: String,
        timestamp_ms: u64,
    }

    fun init(ctx: &mut TxContext) {
        let policy = DetectionPolicy {
            id: object::new(ctx),
            admin: tx_context::sender(ctx),
            anomaly_threshold: 85,
            authorized_ai_agents: table::new(ctx),
        };
        transfer::share_object(policy);
    }

    /// Register or authorize an AI Agent key (Admin-Only)
    public fun authorize_ai_agent(
        policy: &mut DetectionPolicy,
        ai_agent_addr: address,
        is_active: bool,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == policy.admin, ENOT_ADMIN);
        if (table::contains(&policy.authorized_ai_agents, ai_agent_addr)) {
            let ref = table::borrow_mut(&mut policy.authorized_ai_agents, ai_agent_addr);
            *ref = is_active;
        } else {
            table::add(&mut policy.authorized_ai_agents, ai_agent_addr, is_active);
        }
    }

    /// Update the anomaly classification threshold (Admin-Only)
    public fun update_threshold(
        policy: &mut DetectionPolicy,
        new_threshold: u8,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == policy.admin, ENOT_ADMIN);
        policy.anomaly_threshold = new_threshold;
    }

    /// Submit a verified AI classification report (Called by Talus Off-Chain AI Agent)
    public fun submit_classification(
        policy: &DetectionPolicy,
        agent_id: address,
        telemetry_hash: String,
        anomaly_score: u8,
        classification: String,
        signature: vector<u8>,             // Signed payload
        public_key: vector<u8>,            // Public key of the AI agent
        serialized_payload: vector<u8>,
        timestamp_ms: u64,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        // 1. Verify that the sender is an authorized AI Agent
        assert!(table::contains(&policy.authorized_ai_agents, sender), EUNAUTHORIZED_MODEL);
        assert!(*table::borrow(&policy.authorized_ai_agents, sender), EMODEL_INACTIVE);

        // 2. Cryptographic verification of the signed payload using native Sui Ed25519 signature validation
        assert!(ed25519::ed25519_verify(&signature, &public_key, &serialized_payload), EINVALID_SIGNATURE);

        let mut action_taken = std::string::utf8(b"NONE");

        // 3. Evaluate threat threshold
        if (anomaly_score >= policy.anomaly_threshold) {
            action_taken = std::string::utf8(b"TRIGGER_ISOLATION");
        };

        // 4. Emit event for the response subsystem (Mowa agents) to capture
        event::emit(ClassificationReported {
            agent_id,
            telemetry_hash,
            anomaly_score,
            classification,
            action_taken,
            timestamp_ms,
        });
    }
}
