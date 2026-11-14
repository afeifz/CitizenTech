
# Manual de Operação — CitizenTech

## 1. Acesso à máquina virtual

Conectar à VM por SSH:

```bash
ssh mohamedafif@192.168.56.10
```

## 2. Acessar o projeto

```bash
cd ~/citizentech
```

## 3. Gerenciamento do servidor web

Verificar o Nginx:

```bash
sudo systemctl status nginx
```

Iniciar:

```bash
sudo systemctl start nginx
```

Parar:

```bash
sudo systemctl stop nginx
```

Reiniciar:

```bash
sudo systemctl restart nginx
```

## 4. Gerenciamento do monitoramento

Verificar o serviço:

```bash
sudo systemctl status citizentech-monitor.service
```

Iniciar:

```bash
sudo systemctl start citizentech-monitor.service
```

Parar:

```bash
sudo systemctl stop citizentech-monitor.service
```

Reiniciar:

```bash
sudo systemctl restart citizentech-monitor.service
```

Verificar inicialização automática:

```bash
sudo systemctl is-enabled citizentech-monitor.service
```

## 5. Consultar os logs

Log do monitoramento:

```bash
sudo tail -n 30 logs/monitoramento-sistema.log
```

Log da auditoria:

```bash
sudo cat logs/auditoria.log
```

Registros do systemd:

```bash
sudo journalctl -u citizentech-monitor.service -n 30 --no-pager
```

## 6. Executar auditoria

```bash
sudo bash scripts/04-auditar-sistema.sh
```

## 7. Verificar firewall

```bash
sudo ufw status verbose
```

## 8. Verificar rede

```bash
ip -br address
```

## 9. Reconfigurar infraestrutura

O script de provisionamento pode ser executado com:

```bash
sudo bash scripts/01-provisionar-infra.sh
```

O script de firewall pode ser executado com:

```bash
sudo bash scripts/02-configurar-firewall.sh
```

Atenção: a reexecução dos scripts de provisionamento pode alterar configurações de rede e firewall. Faça isso somente quando necessário.

## 10. Acesso ao painel web

Endereço:

http://192.168.56.10

O painel apresenta informações simuladas de sensores e eventos de alagamento.
