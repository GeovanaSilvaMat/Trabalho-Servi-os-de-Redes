#!/bin/bash

# Habilita roteamento IP
echo 1 > /proc/sys/net/ipv4/ip_forward

# Políticas padrão
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Limpa regras existentes
iptables -F
iptables -t nat -F

# Regras de INPUT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

# NAT para saída da rede client_network (rede interna)
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o eth0 -j MASQUERADE

# Encaminhamento entre redes
iptables -A FORWARD -s 192.168.2.0/24 -d 192.168.1.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.1.0/24 -d 192.168.2.0/24 -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir tráfego DNS (UDP e TCP) para a rede client_network
iptables -A FORWARD -p udp -s 192.168.2.0/24 --dport 53 -j ACCEPT  # DNS UDP
iptables -A FORWARD -p tcp -s 192.168.2.0/24 --dport 53 -j ACCEPT  # DNS TCP

# Permitir tráfego HTTP para o web server
iptables -A FORWARD -p tcp -s 192.168.2.0/24 -d 192.168.1.10 --dport 80 -j ACCEPT  # Web

# Permitir tráfego FTP
iptables -A FORWARD -p tcp -s 192.168.2.0/24 -d 192.168.1.6 --dport 21 -j ACCEPT    # FTP
iptables -A FORWARD -p tcp -s 192.168.2.0/24 -d 192.168.1.6 --dport 21100:21110 -j ACCEPT # FTP PASV

# Permitir tráfego Samba
iptables -A FORWARD -p tcp -s 192.168.2.0/24 -d 192.168.1.5 --dport 139 -j ACCEPT    # Samba
iptables -A FORWARD -p tcp -s 192.168.2.0/24 -d 192.168.1.5 --dport 445 -j ACCEPT    # Samba

# Permitir tráfego LDAP
iptables -A FORWARD -p tcp -s 192.168.2.0/24 -d 192.168.1.4 --dport 389 -j ACCEPT    # LDAP

# Log de pacotes DROP (opcional, ajuda a depurar)
# iptables -A INPUT -j LOG --log-prefix "INPUT DROP: "
# iptables -A FORWARD -j LOG --log-prefix "FORWARD DROP: "