
#!/bin/bash
set -Eeuo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_DIR="$PROJECT_DIR/web"
WEB_ROOT="/var/www/citizentech"
LOG_FILE="$PROJECT_DIR/logs/provisionamento-aplicacao.log"

mkdir -p "$PROJECT_DIR/logs"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" | tee -a "$LOG_FILE"
}

fail() {
    log "ERRO" "$1"
    exit 1
}

trap 'fail "Falha na linha $LINENO durante o provisionamento."' ERR

log "INFO" "Iniciando provisionamento da aplicação CitizenTech."

if [[ "$EUID" -ne 0 ]]; then
    fail "Execute este script com sudo."
fi

if [[ ! -f "$WEB_DIR/package.json" ]]; then
    fail "package.json não encontrado em $WEB_DIR."
fi

for command in node npm nginx; do
    command -v "$command" >/dev/null 2>&1 || fail "$command não está instalado."
done

log "INFO" "Node.js: $(node --version)"
log "INFO" "npm: $(npm --version)"

log "INFO" "Instalando dependências da aplicação."
cd "$WEB_DIR"
npm ci

log "INFO" "Validando código com ESLint."
npm run lint

log "INFO" "Gerando build de produção."
npm run build

if [[ ! -f "$WEB_DIR/dist/index.html" ]]; then
    fail "Build não gerou o arquivo index.html."
fi

log "INFO" "Publicando arquivos no diretório do Nginx."
mkdir -p "$WEB_ROOT"
find "$WEB_ROOT" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
cp -a "$WEB_DIR/dist/." "$WEB_ROOT/"
chown -R www-data:www-data "$WEB_ROOT"

log "INFO" "Validando configuração do Nginx."
nginx -t

log "INFO" "Reiniciando Nginx."
systemctl enable nginx
systemctl restart nginx

if ! systemctl is-active --quiet nginx; then
    fail "Nginx não iniciou corretamente."
fi

if ! curl -fsS http://localhost/ >/dev/null; then
    fail "Aplicação não respondeu via HTTP."
fi

log "OK" "Aplicação CitizenTech provisionada com sucesso."
log "OK" "Endereço: http://192.168.56.10"
