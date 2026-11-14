
#!/bin/bash

# =====================================================
# CITIZENTECH - PROVISIONAMENTO DE INFRAESTRUTURA
# Script: 01-provisionar-infra.sh
# =====================================================

set -Eeuo pipefail

# Identificação do projeto
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/provisionamento.log"
NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"
BACKUP_DIR="/var/backups/citizentech"

# Criar diretório de logs
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# Permitir que o usuário normal leia os logs
if [[ -n "${SUDO_USER:-}" ]]; then
    chown "$SUDO_USER" "$LOG_FILE"
fi

# Registrar saída e erros
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " INICIANDO PROVISIONAMENTO CITIZENTECH"
echo " Data: $(date '+%d/%m/%Y %H:%M:%S')"
echo "=========================================="

# Verificar privilégios
if [[ $EUID -ne 0 ]]; then
    echo "[ERRO] Execute este script com sudo."
    exit 1
fi

# Verificar ferramentas necessárias
for cmd in hostnamectl netplan ip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[ERRO] Ferramenta não encontrada: $cmd"
        exit 1
    fi
done

# Verificar interfaces
for interface in enp0s3 enp0s8; do
    if ! ip link show "$interface" >/dev/null 2>&1; then
        echo "[ERRO] Interface $interface não encontrada."
        exit 1
    fi
done

# Verificar arquivo Netplan
if [[ ! -f "$NETPLAN_FILE" ]]; then
    echo "[ERRO] Arquivo Netplan não encontrado."
    exit 1
fi

# Backup da configuração original
mkdir -p "$BACKUP_DIR"
if [[ ! -f "$BACKUP_DIR/00-installer-config.yaml.bak" ]]; then
    cp -a "$NETPLAN_FILE" "$BACKUP_DIR/00-installer-config.yaml.bak"
    echo "[INFO] Backup original criado."
else
    echo "[INFO] Backup original preservado."
fi

echo "[INFO] Backup da configuração de rede realizado."

# Configurar hostname
hostnamectl set-hostname citizentech
echo "[OK] Hostname configurado: citizentech"

# Configurar rede e DNS
cat > "$NETPLAN_FILE" <<'EOF'
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
      dhcp6: true
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8

    enp0s8:
      dhcp4: false
      dhcp6: false
      addresses:
        - 192.168.56.10/24
EOF

echo "[INFO] Nova configuração Netplan criada."

# Validar configuração
if ! netplan generate; then
    echo "[ERRO] Configuração inválida. Restaurando backup."
    cp -a "$BACKUP_DIR/00-installer-config.yaml.bak" "$NETPLAN_FILE"
    netplan generate
    exit 1
fi

# Aplicar configuração
if ! netplan apply; then
    echo "[ERRO] Falha ao aplicar rede. Restaurando backup."
    cp -a "$BACKUP_DIR/00-installer-config.yaml.bak" "$NETPLAN_FILE"
    netplan generate
    netplan apply
    exit 1
fi

echo "[OK] Configuração de rede aplicada."

# Verificar endereço IP
if ip -4 addr show enp0s8 | grep -q "192.168.56.10/24"; then
    echo "[OK] IP estático configurado corretamente."
else
    echo "[ERRO] IP estático não encontrado."
    exit 1
fi

# Verificar conectividade
if ping -c 2 -W 3 8.8.8.8 >/dev/null 2>&1; then
    echo "[OK] Conectividade com a internet funcionando."
else
    echo "[AVISO] Não foi possível alcançar 8.8.8.8."
fi

if getent hosts google.com >/dev/null 2>&1; then
    echo "[OK] Resolução DNS funcionando."
else
    echo "[AVISO] Resolução DNS não funcionou."
fi

echo "=========================================="
echo " PROVISIONAMENTO FINALIZADO"
echo " Hostname: $(hostname)"
echo " IP Host-only: 192.168.56.10"
echo " Log: $LOG_FILE"
echo "=========================================="

