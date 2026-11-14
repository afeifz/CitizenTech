
#!/bin/bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$PROJECT_DIR/logs/execucao-completa.log"

mkdir -p "$PROJECT_DIR/logs"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" | tee -a "$LOG_FILE"
}

if [[ "$EUID" -ne 0 ]]; then
    echo "Execute com sudo: sudo bash scripts/00-executar-tudo.sh"
    exit 1
fi

run_script() {
    local script="$1"

    if [[ ! -f "$PROJECT_DIR/scripts/$script" ]]; then
        log "ERRO" "Script não encontrado: $script"
        exit 1
    fi

    log "INFO" "Executando $script"
    bash "$PROJECT_DIR/scripts/$script"
    log "OK" "$script concluído."
}

log "INFO" "INICIANDO PROVISIONAMENTO COMPLETO CITIZENTECH"

run_script "01-provisionar-infra.sh"
run_script "02-configurar-firewall.sh"
run_script "05-provisionar-aplicacao.sh"

log "INFO" "Verificando serviço de monitoramento."

systemctl enable --now citizentech-monitor.service

if ! systemctl is-active --quiet citizentech-monitor.service; then
    log "ERRO" "Serviço de monitoramento não está ativo."
    exit 1
fi

log "OK" "Serviço de monitoramento ativo."

run_script "04-auditar-sistema.sh"

log "OK" "PROVISIONAMENTO COMPLETO FINALIZADO COM SUCESSO."
