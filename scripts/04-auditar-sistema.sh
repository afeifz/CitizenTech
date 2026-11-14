#!/bin/bash

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$PROJECT_DIR/logs/auditoria.log"

mkdir -p "$PROJECT_DIR/logs"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_service() {
    local service="$1"

    if systemctl is-active --quiet "$service"; then
        log "[OK] Serviço $service está ativo."
    else
        log "[ERRO] Serviço $service não está ativo."
    fi
}

log "========== INÍCIO DA AUDITORIA =========="

log "[INFO] Hostname: $(hostname)"
log "[INFO] Data: $(date)"

check_service nginx
check_service citizentech-monitor.service
check_service ufw

if [[ -f "$PROJECT_DIR/logs/monitoramento-sistema.log" ]]; then
    log "[OK] Arquivo de monitoramento encontrado."
else
    log "[ERRO] Arquivo de monitoramento ausente."
fi

if [[ -f /etc/netplan/00-installer-config.yaml ]]; then
    log "[OK] Configuração Netplan encontrada."
else
    log "[ERRO] Configuração Netplan ausente."
fi

if curl -fsS http://localhost/ > /dev/null; then
    log "[OK] Aplicação web respondendo via HTTP."
else
    log "[ERRO] Aplicação web não respondeu via HTTP."
fi

log "========== FIM DA AUDITORIA =========="
