# CYNA - Partie DevOps et Monitoring

Ce dossier contient ma partie DevOps du projet CYNA.

L'objectif est de montrer comment automatiser une partie de l'infrastructure et mettre en place une supervision simple du serveur web.

La chaîne mise en place est la suivante :

```text
Terraform -> Ansible -> WEB-CYNA -> Prometheus -> Grafana -> Alerte Discord
```

## Architecture utilisée

La maquette est composée de plusieurs machines :

* pfSense-CYNA : pare-feu principal
* DC1-Cyna : serveur interne
* WEB-CYNA : serveur web en DMZ
* ANSIBLE-CYNAA : machine DevOps avec Terraform, Ansible, Prometheus et Grafana

Réseaux utilisés :

* LAN interne : 10.0.20.0/24
* DMZ : 10.0.10.0/24
* OPT2 : 10.0.40.0/24

Adresses importantes :

* pfSense LAN : 10.0.20.1
* pfSense DMZ : 10.0.10.1
* DC1-Cyna : 10.0.20.10
* ANSIBLE-CYNAA : 10.0.20.30
* WEB-CYNA : 10.0.10.10

## Terraform

Le dossier `terraform-cyna/` contient la partie Terraform.

Terraform permet de centraliser les informations de la maquette et de générer automatiquement un inventaire Ansible.

Commandes utilisées :

```bash
cd terraform-cyna
terraform init
terraform fmt
terraform validate
terraform apply -auto-approve
terraform output
```

Fichiers générés :

* `generated/inventory.ini`
* `generated/architecture-cyna.txt`

L'inventaire généré par Terraform est ensuite utilisé par Ansible.

## Ansible

Ansible est utilisé pour configurer le serveur WEB-CYNA à distance.

Test de connexion :

```bash
ansible -i inventory.ini web -m ping --ask-pass
```

Test avec l'inventaire généré par Terraform :

```bash
ansible -i terraform-cyna/generated/inventory.ini web -m ping --ask-pass
```

Playbooks présents :

* `deploy-nginx.yml` : installation de Nginx et déploiement de la page web CYNA
* `install-node-exporter.yml` : installation de Node Exporter sur WEB-CYNA

## Serveur web

Le serveur WEB-CYNA est placé en DMZ avec l'adresse :

```text
10.0.10.10
```

Nginx est installé sur ce serveur pour afficher une page web de démonstration.

Test :

```bash
curl http://10.0.10.10
```

## Monitoring

Node Exporter est installé sur WEB-CYNA.
Il expose les métriques système sur le port 9100.

URL Node Exporter :

```text
http://10.0.10.10:9100/metrics
```

Prometheus est installé sur ANSIBLE-CYNAA et récupère les métriques de WEB-CYNA.

URL Prometheus :

```text
http://10.0.20.30:9090
```

Grafana est aussi installé sur ANSIBLE-CYNAA.

URL Grafana :

```text
http://10.0.20.30:3000
```

## Dashboard Grafana

Un dashboard nommé `Monitoring WEB-CYNA` a été créé.

Il contient trois panneaux :

* état de WEB-CYNA
* charge système
* mémoire disponible

Ce dashboard permet de vérifier rapidement si le serveur web est actif et surveillé.

## Alerte Grafana

Une alerte a été créée dans Grafana :

```text
WEB-CYNA Node Exporter DOWN
```

Elle utilise la métrique :

```text
up{job="web-cyna-node-exporter"}
```

Fonctionnement :

* `up = 1` : le serveur répond correctement
* `up = 0` : Node Exporter ne répond plus

Une notification Discord est envoyée quand l'alerte se déclenche et quand elle revient à la normale.

## Simulation d'incident

Arrêt de Node Exporter avec Ansible :

```bash
ansible -i inventory.ini web -m service -a "name=prometheus-node-exporter state=stopped" --become --ask-pass --ask-become-pass
```

Résultat attendu :

* Prometheus détecte que la cible est DOWN
* Grafana déclenche l'alerte
* Discord reçoit une notification

Redémarrage de Node Exporter avec Ansible :

```bash
ansible -i inventory.ini web -m service -a "name=prometheus-node-exporter state=started enabled=yes" --become --ask-pass --ask-become-pass
```

Résultat attendu :

* Prometheus repasse la cible en UP
* Grafana repasse l'alerte en Normal / Resolved
* Discord reçoit une notification de résolution

## Conclusion

Cette partie montre une chaîne DevOps simple et fonctionnelle :

* Terraform prépare les informations d'infrastructure
* Ansible configure le serveur WEB-CYNA
* Prometheus récupère les métriques
* Grafana affiche les données
* Discord reçoit les alertes
* Ansible permet de corriger rapidement un incident
