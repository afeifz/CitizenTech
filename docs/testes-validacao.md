
# Testes e Validação — CitizenTech

## 1. Objetivo

Este documento registra os testes realizados para validar o funcionamento da infraestrutura CitizenTech.

## 2. Teste de monitoramento

**Objetivo:** verificar a coleta de informações de CPU, RAM e disco.

Comando utilizado:

```bash
sudo bash scripts/03-monitorar-sistema.sh
```

Resultado observado:

| Recurso | Utilização observada |
|---|---:|
| CPU | 2% |
| RAM | 15% |
| Disco | 56% |

Resultado: aprovado.

Os dados foram registrados em `logs/monitoramento-sistema.log`.

## 3. Teste do serviço systemd

**Objetivo:** verificar se o serviço de monitoramento está ativo e habilitado para iniciar automaticamente.

Comando:

```bash
sudo systemctl status citizentech-monitor.service
```

Resultado observado:

- Serviço carregado corretamente.
- Serviço habilitado.
- Estado: active (running).

Resultado: aprovado.

## 4. Teste de recuperação automática

**Objetivo:** verificar se o systemd recupera o serviço após uma falha.

Comando utilizado para simular a falha:

```bash
sudo systemctl kill --signal=KILL citizentech-monitor.service
```

Verificação:

```bash
sudo systemctl status citizentech-monitor.service
sudo systemctl show citizentech-monitor.service -p NRestarts
```

Resultado observado:

- O processo foi encerrado com SIGKILL.
- O systemd identificou a falha.
- O serviço foi iniciado novamente.
- Contador de reinicializações: 1.

Resultado: aprovado.

## 5. Teste dos registros

Comandos utilizados:

```bash
sudo journalctl -u citizentech-monitor.service -n 30 --no-pager
```

```bash
sudo tail -n 30 logs/monitoramento-sistema.log
```

Resultado: os registros de execução, falha e recuperação foram encontrados.

## 6. Teste de auditoria

Comando utilizado:

```bash
sudo bash scripts/04-auditar-sistema.sh
```

Verificações realizadas:

- Hostname.
- Serviço Nginx.
- Serviço de monitoramento.
- Firewall UFW.
- Arquivo de monitoramento.
- Configuração Netplan.
- Resposta HTTP da aplicação.

Resultado: todos os itens apresentaram resultado OK.

## 7. Teste de firewall

Comando utilizado:

```bash
sudo ufw status verbose
```

Resultado observado:

- Firewall ativo.
- Política padrão: bloquear conexões de entrada.
- Política de saída: permitir.
- SSH permitido na porta TCP 22 pela rede 192.168.56.0/24.
- HTTP permitido na porta TCP 80 pela rede 192.168.56.0/24.

Resultado: aprovado.

## 8. Teste de inicialização automática

Comando:

```bash
systemctl is-enabled nginx citizentech-monitor.service
```

Resultado observado:

- Nginx: enabled.
- CitizenTech Monitor: enabled.

Resultado: aprovado.

## 9. Considerações finais

Os testes realizados demonstraram o funcionamento do servidor web, monitoramento de recursos, firewall, auditoria e recuperação automática de falhas por meio do systemd.

Os resultados foram registrados nos arquivos de log do projeto.
