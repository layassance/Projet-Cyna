# Commandes utiles CYNA Ansible

Tester le serveur web :

```bash
ansible -i inventories/lab/hosts.ini web -m ping
```

Tester toutes les machines Linux :

```bash
ansible -i inventories/lab/hosts.ini linux_targets -m ping
```

Déployer Nginx :

```bash
ansible-playbook -i inventories/lab/hosts.ini playbooks/deploy_web.yml
```

Installer Node Exporter :

```bash
ansible-playbook -i inventories/lab/hosts.ini playbooks/install_node_exporter.yml
```

Vérifier les services :

```bash
ansible-playbook -i inventories/lab/hosts.ini playbooks/validate.yml
```

PRA simple serveur web :

```bash
ansible-playbook -i inventories/lab/hosts.ini playbooks/pra_restart_web.yml
```
