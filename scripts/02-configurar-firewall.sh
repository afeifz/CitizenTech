
#!/bin/bash

# =====================================================
# CITIZENTECH - CONFIGURACAO DE FIREWALL
# Script: 02-configurar-firewall.sh
# =====================================================

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/firewall.log"

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

if [[ -n "${SUDO_USER:-}" ]]; then
    chown "$SUDO_USER" "$LOG_FILE"
fi

exec > >(tee -a "$LOG_FILE") 2>&1

trap 'echo "[ERRO] Falha na linha $LINENO. Consulte o log."' ERR

echo "======================================"
echo " INICIANDO CONFIGURACAO DO FIREWALL"
echo " Data: $(date)"
echo "======================================"

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo "[ERRO] Execute com sudo."
    exit 1
fi

# Instalar UFW caso necessario
if ! command -v ufw >/dev/null 2>&1; then
    echo "[INFO] Instalando UFW..."
    apt-get update
    apt-get install -y ufw
fi

# Configurar politicas padrao
ufw default deny incoming
ufw default allow outgoing

# Permitir SSH apenas pela rede Host-only
ufw allow from 192.168.56.0/24 to any port 22 proto tcp

# Permitir HTTP pela rede Host-only
ufw allow from 192.168.56.0/24 to any port 80 proto tcp

echo "[OK] Regras de firewall configuradas."

# Ativar firewall
ufw --force enable

echo "[OK] Firewall ativado."

# Exibir status
ufw status verbose

echo "======================================"
echo " FIREWALL CONFIGURADO COM SUCESSO"
echo " Log: $LOG_FILE"
echo "======================================"
