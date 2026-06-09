module thorium_edr::polonium_policy {
    use std::string::String;
    use sui::event;

    // Error codes
    const ENOT_ADMIN: u64 = 401;

    /// Config structure representing the on-chain Polonium configuration panel
    /// actual configuration is stored encrypted on Walrus
    public struct PoloniumConfig has key, store {
        id: UID,
        admin: address,
        // The storage pointer pointing to the encrypted policy payload on Walrus
        walrus_blob_id: String,
        // SHA-256 integrity hash of the encrypted policy payload
        policy_hash: vector<u8>,
        // Expiration timestamp to enforce regular audits on-chain
        expires_at_ms: u64,
    }

    /// Event emitted when policy changes are made on-chain
    public struct PolicyUpdated has copy, drop {
        admin: address,
        walrus_blob_id: String,
        policy_hash: vector<u8>,
        expires_at_ms: u64,
    }

    fun init(ctx: &mut TxContext) {
        let config = PoloniumConfig {
            id: object::new(ctx),
            admin: tx_context::sender(ctx),
            // Default placeholder Walrus blob ID
            walrus_blob_id: std::string::utf8(b"walrus:blob:placeholder_polonium_config_v1"),
            policy_hash: vector[],
            // Default expiration set to a timestamp in the future (30 days)
            expires_at_ms: 1783300000000, 
        };
        transfer::share_object(config);
    }

    /// Update complete policy configuration pointers (Admin-Only)
    public fun update_policy(
        config: &mut PoloniumConfig,
        walrus_blob_id: String,
        policy_hash: vector<u8>,
        expires_at_ms: u64,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == config.admin, ENOT_ADMIN);
        config.walrus_blob_id = walrus_blob_id;
        config.policy_hash = policy_hash;
        config.expires_at_ms = expires_at_ms;

        event::emit(PolicyUpdated {
            admin: config.admin,
            walrus_blob_id,
            policy_hash,
            expires_at_ms,
        });
    }
}
