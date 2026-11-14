# Arquitetura do Projeto CitizenTech

## 1. Visão geral

O CitizenTech é uma solução demonstrativa de monitoramento de áreas sujeitas a alagamentos.

O projeto utiliza uma infraestrutura Linux para hospedar um painel web de monitoramento e executar rotinas de administração, segurança, auditoria e monitoramento do sistema.

A aplicação web utiliza dados simulados para representar sensores de monitoramento de alagamentos.

## 2. Ambiente utilizado

- Sistema operacional: Ubuntu Server 26.04.1 LTS
- Virtualização: Oracle VirtualBox
- Arquitetura: x86-64
- Servidor web: Nginx
- Aplicação web: React e Vite
- Runtime JavaScript: Node.js
- Firewall: UFW
- Monitoramento: Bash
- Gerenciamento de serviços: systemd

## 3. Configuração de rede

A máquina virtual utiliza dois adaptadores de rede:

| Interface | Tipo | Endereço IP |
|---|---|---|
| enp0s3 | NAT | 10.0.2.15 |
| enp0s8 | Host-only | 192.168.56.10 |

A interface NAT permite acesso à internet pela máquina virtual.

A interface Host-only permite a comunicação entre o computador hospedeiro e a máquina virtual.

O DNS utiliza os servidores:

- 1.1.1.1
- 8.8.8.8

## 4. Segurança e firewall

O firewall UFW foi configurado com as seguintes políticas:

- Bloquear conexões de entrada por padrão.
- Permitir conexões de saída.
- Permitir SSH pela porta TCP 22 somente pela rede 192.168.56.0/24.
- Permitir HTTP pela porta TCP 80 somente pela rede 192.168.56.0/24.

Essa configuração restringe o acesso aos serviços da máquina virtual à rede Host-only.

## 5. Servidor web

O Nginx é responsável por disponibilizar a aplicação web CitizenTech.

Os arquivos de produção da aplicação React são gerados pelo Vite e publicados no diretório:

`/var/www/citizentech`

O acesso ao painel é realizado pelo endereço:

`http://192.168.56.10`

## 6. Monitoramento do sistema

O projeto possui um script Bash responsável por monitorar:

- Utilização da CPU.
- Utilização da memória RAM.
- Utilização do disco.

Os limites são definidos no arquivo:

`config/monitoramento.conf`

Valores configurados:

| Recurso | Limite de alerta |
|---|---:|
| CPU | 80% |
| RAM | 80% |
| Disco | 85% |

O intervalo entre verificações é de 30 segundos.

Os resultados são registrados em:

`logs/monitoramento-sistema.log`

## 7. Serviço systemd

O monitoramento é executado por meio do serviço:

`citizentech-monitor.service`

O serviço foi configurado para:

- Iniciar automaticamente com o sistema.
- Executar o script de monitoramento como root.
- Reiniciar automaticamente em caso de falha.
- Aguardar cinco segundos antes de tentar reiniciar.

A recuperação automática foi testada por meio do encerramento forçado do processo com SIGKILL.

O systemd identificou a falha e reiniciou o serviço com sucesso.

## 8. Auditoria

O script `scripts/04-auditar-sistema.sh` verifica:

- Hostname da máquina.
- Estado do Nginx.
- Estado do serviço de monitoramento.
- Estado do UFW.
- Existência do arquivo de monitoramento.
- Existência da configuração Netplan.
- Resposta HTTP da aplicação web.

Os resultados são armazenados em:

`logs/auditoria.log`

## 9. Estrutura do projeto

```text
citizentech/
├── config/
├── docs/
├── evidence/
├── logs/
├── scripts/
└── web/
```
Cada diretório possui uma responsabilidade:
- config: configurações do monitoramento.
- docs: documentação técnica.
- evidence: evidências e backups.
- logs: registros de execução.
- scripts: scripts de administração.
- web: código-fonte da aplicação.

## 10. Considerações finais

A infraestrutura CitizenTech demonstra a utilização de recursos de administração Linux, configuração de rede, segurança, hospedagem web, monitoramento de recursos, gerenciamento de serviços e auditoria.

A aplicação web utiliza dados simulados e tem finalidade demonstrativa.
