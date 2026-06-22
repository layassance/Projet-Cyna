# Règles pfSense à prévoir

Si Ansible est lancé depuis le VLAN20 vers le serveur web en DMZ, prévoir au minimum :

- VLAN20 -> 10.0.10.10 TCP/22 pour SSH Ansible
- VLAN20 -> 10.0.10.10 TCP/80 pour tester Nginx
- VLAN20 -> 10.0.10.10 TCP/9100 pour Node Exporter

Pour Wazuh en VLAN20 :

- VLAN20 -> 10.0.20.20 TCP/22 pour SSH Ansible
- VLAN20 -> 10.0.20.20 TCP/9100 pour Node Exporter

Ne pas ouvrir plus que nécessaire.
