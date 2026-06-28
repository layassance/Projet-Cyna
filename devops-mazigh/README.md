# CYNA - DevOps, IaC et Monitoring

## Objectif

Ce dépôt contient ma partie DevOps du projet CYNA.

L'objectif est de montrer une chaîne simple et fonctionnelle :

Terraform -> Ansible -> WEB-CYNA -> Prometheus -> Grafana -> Alerte Discord -> Correction avec Ansible

Cette partie permet de démontrer l'automatisation, la supervision et la réaction à un incident simple.

## Architecture de la maquette

La maquette est composée de plusieurs VM :

* pfSense-CYNA : pare-feu central de la maquette
* DC1-Cyna : serveur interne
* WEB-CYNA : serveur web placé en DMZ
* ANSIBLE-CYNAA : machine DevOps avec Terraform, Ansible, Prometheus et Grafana

Réseaux utilisés :

* LAN interne : 10.0.20.0/24
* DMZ : 10.0.10.0/24
* OPT2 : 10.0.40.0/24

Adresses principales :

* pfSense LAN : 10.0.20.1
* pfSense DMZ : 10.0.10.1
* DC1-Cyna : 10.0.20.10
* ANSIBLE-CYNAA : 10.0.20.30
* WEB-CYNA : 10.0.10.10

## Terraform

Le dossier terraform-cyna contient la partie IaC.

Dans cette maquette locale, Terraform ne crée pas directement les VM VirtualBox. Les VM sont déjà créées manuellement. Terraform sert ici à décrire les éléments principaux de l'infrastructure et à générer automatiquement un inventaire Ansible.

Commandes principales :

```bash
cd terraform-cyna
terraform init
terraform fmt
terraform validate
terraform apply -auto-approve
terraform output
```

Terraform génère notamment :

* generated/inventory.ini
* generated/architecture-cyna.txt

L'inventaire généré est ensuite utilisé par Ansible pour administrer WEB-CYNA.

## Ansible

Ansible est utilisé pour configurer le serveur WEB-CYNA à distance.

Test de connexion avec l'inventaire classique :

```bash
ansible -i inventory.ini web -m ping --ask-pass
```

Test de connexion avec l'inventaire généré par Terraform :

```bash
ansible -i terraform-cyna/generated/inventory.ini web -m ping --ask-pass
```

Playbooks présents :

* deploy-nginx.yml : installe Nginx et déploie une page web CYNA
* install-node-exporter.yml : installe Node Exporter sur WEB-CYNA

## Serveur web

WEB-CYNA est placé en DMZ avec l'adresse :

```text
10.0.10.10
```

Nginx est installé sur WEB-CYNA. Il sert à héberger une page web de démonstration CYNA.

Test du serveur web :

```bash
curl http://10.0.10.10
```

## Monitoring

Node Exporter est installé sur WEB-CYNA. Il expose les métriques système du serveur sur le port 9100.

URL Node Exporter :

```text
http://10.0.10.10:9100/metrics
```

Prometheus est installé sur ANSIBLE-CYNAA. Il récupère les métriques de WEB-CYNA.

URL Prometheus :

```text
http://10.0.20.30:9090
```

Grafana est installé sur ANSIBLE-CYNAA. Il affiche les métriques dans un dashboard nommé :

```text
Monitoring WEB-CYNA
```

URL Grafana :

```text
http://10.0.20.30:3000
```

## Dashboard Grafana

Le dashboard Grafana contient trois panneaux :

* Etat WEB-CYNA
* Charge systeme WEB-CYNA
* Memoire disponible WEB-CYNA

Ces panneaux permettent de vérifier rapidement l'état technique du serveur WEB-CYNA.

## Alerte Grafana

Une alerte Grafana a été créée :

```text
WEB-CYNA Node Exporter DOWN
```

La condition est basée sur la métrique :

```text
up{job="web-cyna-node-exporter"}
```

Logique :

* up = 1 : WEB-CYNA est surveillé correctement
* up = 0 : Node Exporter ne répond plus

Une notification Discord est envoyée lorsque l'alerte se déclenche ou revient à la normale.

## Simulation d'incident

Pour simuler une panne, on arrête Node Exporter sur WEB-CYNA avec Ansible :

```bash
ansible -i inventory.ini web -m service -a "name=prometheus-node-exporter state=stopped" --become --ask-pass --ask-become-pass
```

Résultat attendu :

* Prometheus voit la cible en DOWN
* Grafana passe l'alerte en Firing
* Discord reçoit une notification

Pour réparer, on redémarre Node Exporter avec Ansible :

```bash
ansible -i inventory.ini web -m service -a "name=prometheus-node-exporter state=started enabled=yes" --become --ask-pass --ask-become-pass
```

Résultat attendu :

* Prometheus repasse la cible en UP
* Grafana repasse l'alerte en Normal ou Resolved
* Discord reçoit une notification de résolution

## Limites

Dans cette maquette, Terraform ne provisionne pas directement les VM. Dans une vraie infrastructure, Terraform pourrait créer les VM, les réseaux, les règles de sécurité ou les ressources cloud.

Ici, Terraform sert à structurer l'infrastructure et à générer l'inventaire Ansible de manière reproductible.

La partie Wazuh / SIEM est traitée séparément dans le projet global.
