#!/bin/bash
# =============================================================
# 🛡️ Thorium XDR Agent - AlmaLinux 9 Provisioning Script
# =============================================================
set -e

# --- Fix systemd warning about rc.local ---
if [ -f /etc/rc.d/rc.local ]; then
  chmod +x /etc/rc.d/rc.local
fi

VM_NAME="${VM_NAME:-thorium-vm}"
SUI_CONTRACT="${SUI_CONTRACT:-0x0cc3f972285b0486b2590b5edc9321813ec32a253a26cffa687da5a1131491af}"
MACHINE_TYPE="${MACHINE_TYPE:-Server}"
OWNER_NAME="${OWNER_NAME:-Jakub}"
IPV6_ADDRESS="${IPV6_ADDRESS:-fde4:8dba:82e1::11}"

echo "=================================================="
echo "🛡️ THORIUM XDR - PROVISIONING ALMALINUX 9 VM"
echo "   VM Name: $VM_NAME"
echo "=================================================="

# --- 1. Network configuration for static IPv6 ---
if [ -n "$IPV6_ADDRESS" ]; then
    echo "⚙️ Configuring static IPv6 address: $IPV6_ADDRESS"
    if nmcli connection show "System eth1" &>/dev/null; then
        nmcli connection modify "System eth1" ipv6.addresses "$IPV6_ADDRESS/64" ipv6.method manual
        nmcli connection up "System eth1"
        echo "  ✅ Configured static IPv6 on eth1."
    else
        echo "  ⚠️ Connection 'System eth1' not found."
    fi
fi

# --- 2. System dependencies ---
echo "[1/6] Installing system dependencies..."
dnf install -y curl wget openssl openssl-devel gcc make git 2>/dev/null || true
dnf install -y systemd 2>/dev/null || true

# --- 3. Copy binary from synced folder (if available and compatible) ---
echo "[2/6] Deploying Thorium XDR binary..."
systemctl stop thorium-agent || true
mkdir -p /opt/thorium

if [ -f /opt/mowa-src/Mowa_agent_bin ]; then
    cp /opt/mowa-src/Mowa_agent_bin /opt/thorium/thorium-agent
    chmod +x /opt/thorium/thorium-agent
    echo "  ✅ Binary copied from /opt/mowa-src/Mowa_agent_bin."
elif [ -f /opt/mowa-src/target/debug/Mowa ]; then
    cp /opt/mowa-src/target/debug/Mowa /opt/thorium/thorium-agent
    chmod +x /opt/thorium/thorium-agent
    echo "  ✅ Binary copied from host build."
else
    echo "  ⚠️  Binary not found in /opt/mowa-src/target/debug/Mowa"
    echo "  📦 Installing Rust and compiling from source..."
    
    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
    source "$HOME/.cargo/env"
    
    # Build
    cd /opt/mowa-src
    cargo build --bin Mowa 2>&1 | tail -5
    cp /opt/mowa-src/target/debug/Mowa /opt/thorium/thorium-agent
    chmod +x /opt/thorium/thorium-agent
    echo "  ✅ Binary compiled from source."
fi

# --- 4. Copy agent script ---
echo "[4/7] Deploying agent Mowa script..."
cp /opt/mowa-src/thorium/thorium_agent.mowa /opt/thorium/
chown -R root:root /opt/thorium
chmod 700 /opt/thorium/thorium-agent

# --- 5. Create systemd service ---
echo "[5/7] Creating systemd service..."
cat > /etc/systemd/system/thorium-agent.service << EOF
[Unit]
Description=Thorium XDR Security Agent
Documentation=https://github.com/mowa-lang/thorium
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Environment="SUI_CONTRACT=${SUI_CONTRACT}"
Environment="THORIUM_VM_NAME=${VM_NAME}"
Environment="MACHINE_TYPE=${MACHINE_TYPE}"
Environment="OWNER_NAME=${OWNER_NAME}"
Environment="IPV6_ADDRESS=${IPV6_ADDRESS}"
ExecStart=/opt/thorium/thorium-agent uruchom /opt/thorium/thorium_agent.mowa
WorkingDirectory=/opt/thorium
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=thorium-agent

# Security hardening
NoNewPrivileges=no
ProtectHome=no

[Install]
WantedBy=multi-user.target
EOF

# --- 6. Open firewall for agent port ---
echo "[6/7] Configuring firewall..."
if command -v firewall-cmd &>/dev/null; then
    firewall-cmd --permanent --add-port=9090/tcp 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
fi
# Also allow via SELinux if active
if command -v semanage &>/dev/null; then
    semanage port -a -t http_port_t -p tcp 9090 2>/dev/null || true
fi

# --- 7. Enable and start the service ---
echo "[7/7] Starting Thorium XDR Agent service..."
systemctl daemon-reload
systemctl enable thorium-agent
systemctl start thorium-agent

sleep 2

if systemctl is-active --quiet thorium-agent; then
    echo ""
    echo "=================================================="
    echo "✅ THORIUM XDR AGENT DEPLOYED SUCCESSFULLY"
    echo "   VM:      $VM_NAME"
    echo "   API:     http://localhost:9090"
    echo "   Service: systemctl status thorium-agent"
    echo "=================================================="
else
    echo "⚠️  Service may not have started yet (journalctl -u thorium-agent)"
    systemctl status thorium-agent --no-pager || true
fi
