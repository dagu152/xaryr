#!/bin/bash
set -e

USERNAME="dada186"
PORT="1080"
export DEBIAN_FRONTEND=noninteractive

PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 10)

if ! command -v danted >/dev/null 2>&1; then
    apt update -o Acquire::ForceIPv4=true -y
    apt install -o Acquire::ForceIPv4=true -y dante-server curl python3
else
    apt install -o Acquire::ForceIPv4=true -y curl python3 || true
fi

IFACE=$(ip route | awk '/default/ {print $5; exit}')
SERVER_IP=$(curl -4 -s ifconfig.me || curl -4 -s ip.sb)

useradd -M -s /bin/bash "$USERNAME" 2>/dev/null || true
echo "${USERNAME}:${PASSWORD}" | chpasswd

cat > /etc/danted.conf <<EOF
logoutput: syslog
internal: 0.0.0.0 port = $PORT
external: $IFACE
socksmethod: pam
clientmethod: none
user.privileged: root
user.unprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    socksmethod: pam
    protocol: tcp udp
}
EOF

systemctl restart danted
systemctl enable danted

ufw allow ${PORT}/tcp 2>/dev/null || true

ENCODED_PASS=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${PASSWORD}'))")

echo
echo "========================================"
echo " SOCKS5 安装完成"
echo "========================================"
echo "socks5://${USERNAME}:${ENCODED_PASS}@${SERVER_IP}:${PORT}"
echo "========================================"
