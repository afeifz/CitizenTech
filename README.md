
# CitizenTech — Infraestrutura Linux para Monitoramento de Alagamentos

O **CitizenTech** é um projeto acadêmico que demonstra a implementação de uma infraestrutura Linux para hospedar um painel web de monitoramento de áreas sujeitas a alagamentos.

O projeto foi desenvolvido utilizando Ubuntu Server em uma máquina virtual VirtualBox, com automação em Bash, gerenciamento de serviços via systemd, firewall UFW e servidor web Nginx.

## Ficha da CitizenTech

| Campo | Conteúdo |
|---|---|
| **Nome da CitizenTech** | ChuvaSegura |
| **Cidade e bairro** | São Paulo – Ipiranga (região do Rio Tamanduateí) |
| **Cidadão beneficiado** | Moradores e comerciantes do Ipiranga em ruas com histórico de alagamento, com atenção a idosos e pessoas com mobilidade reduzida |
| **Problema, em uma frase** | Moradores de áreas que alagam recebem o aviso de chuva forte tarde demais, ou de forma genérica demais, para proteger a família e seus bens. |
| **Como funciona** | Um sensor mede o nível da água num ponto crítico; um modelo de ML estima a chance de chuva forte; a API combina os dois e envia alertas ao app do morador, que também registra ocorrências. |
| **O que cada parte faz** | IoT (ESP32/Wokwi): mede e sinaliza o nível · API C#: recebe leituras e calcula risco · API Java: cadastro e alertas · ML: previsão de chuva forte com dados do INMET · App Expo: risco do bairro, alertas e ocorrências · **Linux: hospeda e monitora o sistema** · Cybersecurity: protege os dados dos moradores · QA: features e casos de teste |
| **Link do repositório** | https://github.com/afeifz/CitizenTech.git |
| **Indicador de impacto** | Minutos de antecedência entre o alerta e o nível crítico; % de chuvas fortes detectadas pelo modelo (recall) |
| **ODS conectados** | 11 (Cidades sustentáveis), 13 (Ação climática), 9 (Infraestrutura e inovação), 10 (Redução das desigualdades) |


**Equipe:** 

**Mohamed Afif RM 554445**

**Lucca Cardinale RM556668**

**Link do vídeo:** https://youtu.be/Wt1p__2fRF8




## Objetivos

- Configurar uma infraestrutura Linux funcional.
- Automatizar o provisionamento de rede e hostname.
- Implementar regras de segurança com firewall.
- Hospedar uma aplicação web utilizando Nginx.
- Monitorar CPU, memória RAM e armazenamento.
- Registrar eventos e alertas em arquivos de log.
- Implementar recuperação automática de serviços.
- Realizar auditoria da infraestrutura.

## Tecnologias utilizadas

| Tecnologia | Finalidade |
|---|---|
| Ubuntu Server 26.04.1 LTS | Sistema operacional |
| VirtualBox | Virtualização |
| Bash | Automação e monitoramento |
| Netplan | Configuração de rede |
| UFW | Firewall |
| Nginx | Servidor web |
| Node.js | Ambiente JavaScript |
| React + Vite | Aplicação web |
| systemd | Gerenciamento de serviços |

## Arquitetura

A infraestrutura utiliza duas interfaces de rede:

- NAT: acesso à internet.
- Host-only: comunicação entre o computador hospedeiro e a VM.

Endereço de acesso ao painel:

**http://192.168.56.10**

## Funcionalidades implementadas

### Provisionamento
- Configuração de hostname.
- Configuração de IP estático.
- Configuração de servidores DNS.
- Backup da configuração de rede.

### Segurança
- Firewall UFW habilitado.
- Bloqueio de conexões de entrada por padrão.
- Acesso SSH e HTTP restrito à rede Host-only.

### Aplicação web
- Painel de monitoramento CitizenTech.
- Visualização de sensores simulados.
- Indicadores de situação e alertas.
- Histórico de eventos.

### Monitoramento
- Monitoramento de CPU, RAM e disco.
- Limites configuráveis.
- Verificações periódicas a cada 30 segundos.
- Registro de informações e alertas.

### Confiabilidade
- Serviço systemd dedicado.
- Inicialização automática.
- Reinicialização automática após falhas.
- Teste de recuperação utilizando SIGKILL.

### Auditoria
- Verificação de serviços.
- Verificação de arquivos de configuração.
- Verificação da aplicação web.
- Registro dos resultados em arquivo.

## Estrutura do projeto

```text
citizentech/
├── config/
│   └── monitoramento.conf
├── docs/
│   ├── arquitetura.md
│   └── manual-operacao.md
├── evidence/
├── logs/
├── scripts/
│   ├── 01-provisionar-infra.sh
│   ├── 02-configurar-firewall.sh
│   ├── 03-monitorar-sistema.sh
│   └── 04-auditar-sistema.sh
└── web/
    ├── src/
    ├── dist/
    └── package.json
```

## Scripts disponíveis

| Script | Responsabilidade |
|---|---|
| `00-executar-tudo.sh` | Orquestração do provisionamento completo |
| `01-provisionar-infra.sh` | Configuração de hostname, rede e DNS |
| `02-configurar-firewall.sh` | Configuração do firewall UFW |
| `03-monitorar-sistema.sh` | Monitoramento de CPU, RAM e disco |
| `04-auditar-sistema.sh` | Auditoria do sistema |
| `05-provisionar-aplicacao.sh` | Dependências, validação, build e publicação da aplicação |

## Logs

Os registros são armazenados no diretório `logs/`:

- `provisionamento.log`
- `firewall.log`
- `monitoramento-sistema.log`
- `auditoria.log`

Os registros do serviço também podem ser consultados pelo journal do systemd.

## Serviço de monitoramento

Nome do serviço:

`citizentech-monitor.service`

Verificar status:

```bash
sudo systemctl status citizentech-monitor.service
```

Consultar registros:

```bash
sudo journalctl -u citizentech-monitor.service -n 30 --no-pager
```

## Documentação adicional

- [Arquitetura do projeto](docs/arquitetura.md)
- [Manual de operação](docs/manual-operacao.md)

## Observação

O painel web utiliza dados simulados para fins acadêmicos e demonstrativos. Ele não recebe dados reais de sensores físicos nem representa um sistema de alerta público em produção.

## Projeto acadêmico

Desenvolvido como atividade acadêmica da disciplina de Operating Systems.


## Evidências do projeto

As capturas de tela da execução e validação do ambiente estão disponíveis em `evidence/screenshots/`.

1. `01-painel-web.png` — Painel web CitizenTech.
2. `02-rede-linux.png` — Interfaces e endereços IP.
3. `03-firewall.png` — Regras do firewall UFW.
4. `04-monitoramento.png` — Registros de monitoramento.
5. `05-systemd.png` — Status do serviço de monitoramento.
6. `06-recuperacao.png` — Evidência de recuperação automática do serviço.
