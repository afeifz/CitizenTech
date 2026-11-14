#!/bin/bash

set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/config/monitoramento.conf"
LOG_FILE="$PROJECT_DIR/logs/monitoramento-sistema.log"

mkdir -p "$PROJECT_DIR/logs"
touch "$LOG_FILE"

log() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOG_FILE"
}

handle_error() {
    local exit_code=$?
    log "ERRO" "Falha na linha ${BASH_LINENO[0]:-desconhecida}. Código: $exit_code"
    exit "$exit_code"
}

trap handle_error ERR

if [[ $EUID -ne 0 ]]; then
    echo "Execute este script com sudo."
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Arquivo de configuração não encontrado: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

# Validar configurações
for threshold in "$CPU_THRESHOLD" "$RAM_THRESHOLD" "$DISK_THRESHOLD"; do
    if ! [[ "$threshold" =~ ^[0-9]+$ ]] || (( threshold > 100 || threshold < 1 )); then
        echo "Erro: limites devem ser números entre 1 e 100."
        exit 1
    fi
done

if ! [[ "$CHECK_INTERVAL" =~ ^[0-9]+$ ]] || (( CHECK_INTERVAL < 1 )); then
    echo "Erro: CHECK_INTERVAL deve ser um número positivo."
    exit 1
fi

if [[ ! -d "$DISK_PATH" ]]; then
    echo "Erro: caminho de disco inválido: $DISK_PATH"
    exit 1
fi

# Calcula uso da CPU usando duas amostras de /proc/stat
get_cpu_usage() {
    local idle1 total1 idle2 total2

    read -r idle1 total1 < <(
        awk '/^cpu / {
            idle = $5 + $6
            total = 0
            for (i = 2; i <= NF; i++) total += $i
            print idle, total
        }' /proc/stat
    )

    sleep 1

    read -r idle2 total2 < <(
        awk '/^cpu / {
            idle = $5 + $6
            total = 0
            for (i = 2; i <= NF; i++) total += $i
            print idle, total
        }' /proc/stat
    )

    awk -v i1="$idle1" -v t1="$total1" \
        -v i2="$idle2" -v t2="$total2" \
        'BEGIN {
            dt = t2 - t1
            di = i2 - i1
            if (dt <= 0) print 0
            else printf "%.0f", ((dt - di) / dt) * 100
        }'
}

# Calcula uso da memória RAM
get_ram_usage() {
    awk '
        /MemTotal:/ { total = $2 }
        /MemAvailable:/ { available = $2 }
        END {
            if (total > 0)
                printf "%.0f", ((total - available) / total) * 100
            else
                print 0
        }
    ' /proc/meminfo
}

# Calcula uso do disco
get_disk_usage() {
    df -P "$DISK_PATH" | awk 'NR == 2 {
        gsub("%", "", $5)
        print $5
    }'
}

log "INFO" "Monitoramento iniciado."
log "INFO" "CPU: alerta em ${CPU_THRESHOLD}% | RAM: alerta em ${RAM_THRESHOLD}% | Disco: alerta em ${DISK_THRESHOLD}%"

while true; do
    CPU_USAGE="$(get_cpu_usage)"
    RAM_USAGE="$(get_ram_usage)"
    DISK_USAGE="$(get_disk_usage)"

    log "INFO" "CPU: ${CPU_USAGE}% | RAM: ${RAM_USAGE}% | Disco: ${DISK_USAGE}%"

    if (( CPU_USAGE >= CPU_THRESHOLD )); then
        log "ALERTA" "Uso de CPU acima do limite: ${CPU_USAGE}%"
    fi

    if (( RAM_USAGE >= RAM_THRESHOLD )); then
        log "ALERTA" "Uso de RAM acima do limite: ${RAM_USAGE}%"
    fi

    if (( DISK_USAGE >= DISK_THRESHOLD )); then
        log "ALERTA" "Uso de disco acima do limite: ${DISK_USAGE}%"
    fi

    sleep "$CHECK_INTERVAL"
done
