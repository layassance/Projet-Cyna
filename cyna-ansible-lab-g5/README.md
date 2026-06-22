# CYNA - Ansible LAB G5

Base Ansible adaptée à l'infrastructure actuelle du groupe.

## Infrastructure utilisée

- Firewall pfSense / Firewall-geneve
  - LAN / VLAN20 : 10.0.20.1/24
  - DMZ : 10.0.10.1/24
  - VLAN40 : 10.0.40.1/24
  - VPN : 10.10.10.1/24

- Serveur web : 10.0.10.10 / DMZ
- Wazuh : 10.0.20.20 / VLAN20
- DC1-Cyna Windows Server : 10.0.20.10 / VLAN20

## Ce que fait Ansible

Cette base Ansible reste centrée sur les machines Linux :

- installation et configuration de Nginx sur le serveur web ;
- installation de Node Exporter sur les machines Linux à surveiller ;
- vérification de l'état des services ;
- base simple pour la reprise en cas d'incident.

Le serveur Windows DC1-Cyna est indiqué dans l'inventaire à titre d'information, mais il n'est pas utilisé dans les playbooks Linux.

## Prérequis

Depuis la machine qui lance Ansible, il faut pouvoir joindre les VM Linux en SSH :

```bash
ping 10.0.10.10
ping 10.0.20.20
ssh ubuntu@10.0.10.10
ssh ubuntu@10.0.20.20
```

Si SSH n'est pas installé sur une VM Ubuntu/Debian :

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```

## Utilisation

Modifier l'utilisateur SSH dans :

```bash
inventories/lab/hosts.ini
```

Puis lancer :

```bash
ansible -i inventories/lab/hosts.ini web -m ping
ansible -i inventories/lab/hosts.ini linux_targets -m ping
ansible-playbook -i inventories/lab/hosts.ini playbooks/deploy_web.yml
ansible-playbook -i inventories/lab/hosts.ini playbooks/install_node_exporter.yml
ansible-playbook -i inventories/lab/hosts.ini playbooks/validate.yml
```

## Attention

Ne pas lancer les playbooks Linux sur le serveur Windows 10.0.20.10.
Pour gérer Windows avec Ansible, il faudrait configurer WinRM, ce qui n'est pas inclus ici.
