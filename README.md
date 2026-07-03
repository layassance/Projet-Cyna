# Projet CYNA — Infrastructure Systèmes, Réseaux & Cybersécurité

> **Épreuve certifiante BC3 — CPI Bachelor RNCP 38478**  
> INGETIS / SUP DE VINCI — Promo 2025–2026 — Groupe 5

---

## Contexte

CYNA est une société de cybersécurité spécialisée dans la distribution de solutions de protection avancées (SOC, EDR, XDR) et l'édition d'une plateforme SaaS de gestion des infrastructures de sécurité.

Dans le cadre de son expansion stratégique, l'entreprise déploie son nouveau siège social à **Genève** et ouvre une filiale opérationnelle à **Paris**. Ce projet consiste à concevoir, déployer et sécuriser l'infrastructure complète qui supporte ces deux sites, en tenant compte des exigences d'un éditeur de solutions de sécurité : l'infrastructure interne de CYNA se doit d'être une vitrine technologique irréprochable.

---

## Architecture

L'infrastructure repose sur trois blocs distincts, interconnectés de manière sécurisée :

```
[SIÈGE — Genève]          [FILIALE — Paris]
  pfSense (WAN)  <──WireGuard VPN──>  pfSense (WAN)
  │                                    │
  ├── VLAN 10 : Management             └── VLAN 40 : Utilisateurs
  │   └── Poste admin (10.0.10.10)         └── AD Réplica (10.0.40.10)
  │
  ├── VLAN 20 : Serveurs
  │   └── AD Genève (10.0.20.10)
  │
  └── VLAN 30 : SOC/Sécu
      └── Docker : Wazuh + Zabbix (10.0.30.10)
              │
              └── Sauvegardes/Logs
                        │
              [CLOUD — Microsoft Azure]
              ├── snet-pra (10.0.100.0/24)
              │   └── Veeam + WSUS (10.0.100.10)
              └── snet-dmz (10.0.200.0/24)
                  └── Serveur Web public (10.0.200.10)
```

---

## Choix technologiques

| Composant | Technologie | Justification |
|---|---|---|
| Pare-feu | pfSense (FreeBSD) | Open source, richesse fonctionnelle (VLAN, NAT, VPN, ACL), adapté à une PME comme CYNA |
| Hyperviseur (AD) | Microsoft Hyper-V | Intégration native avec Windows Server / AD DS, sans coût de licence supplémentaire |
| Hyperviseur (pfSense + Docker) | VMware Workstation | Contrainte matérielle : la machine Hyper-V ne disposait pas des ressources suffisantes pour héberger toutes les VM |
| VPN site-à-site | WireGuard | Protocole moderne (Curve25519, ChaCha20), configuration simple, performances supérieures à IPsec |
| Annuaire | Microsoft Active Directory (cyna.local) | Gestion centralisée des identités, GPO, réplication multi-sites |
| SIEM / IDS | Wazuh | Agents déployés sur tous les endpoints, alertes temps réel, SCA (Security Configuration Assessment) |
| Supervision infra | Zabbix | Monitoring des hôtes via SNMP/agents, dashboards de performance |
| Conteneurisation | Docker | Mutualisation des services SOC (Wazuh + Zabbix) sur un seul hôte, réduction de l'empreinte mémoire |
| Cloud hybride | Microsoft Azure | Scalabilité, PRA géographiquement distant du site on-premise, exposition publique sécurisée |
| IaC — Cloud | Terraform (provider azurerm) | Provisionnement reproductible des ressources Azure (VNet, NSG, VM) |
| IaC — Config | Ansible | Configuration automatisée des serveurs (hardening, Nginx, agents Wazuh) |
| Sauvegarde / PRA | Veeam Backup & Replication | Sauvegardes automatisées, objectifs RTO/RPO définis |
| Reverse proxy | Nginx | Exposition du site web CYNA depuis la DMZ Azure |

---

## Structure du dépôt

```
Projet-Cyna/
├── terraform/               # Provisionnement des ressources Azure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── ansible/                 # Configuration des serveurs
│   ├── inventory.ini
│   ├── site.yml
│   └── roles/
│       ├── common/          # Hardening (CIS Benchmark)
│       ├── nginx/           # Serveur web
│       ├── wazuh-agent/     # Agent SIEM
│       └── wazuh-manager/   # SIEM Manager
├── docker/                  # Stack Docker SOC
│   └── docker-compose.yml   # Wazuh + OpenSearch + Zabbix
├── docs/
│   ├── network/             # Schéma réseau (PNG + draw.io)
│   ├── security-policy.pdf  # Politique de sécurité
│   ├── sca-report.pdf       # Rapport SCA Wazuh
│   ├── tests/               # Rapports nmap / OWASP ZAP
│   ├── monitoring/          # Config Prometheus + captures
│   └── runbooks/            # Procédures d'exploitation
└── README.md
```

---

## Guide de déploiement

### Prérequis

- Hyper-V (Windows Server ou Windows 10/11 Pro) pour les VM Windows Server
- VMware Workstation pour pfSense et l'hôte Docker
- Terraform ≥ 1.5
- Ansible ≥ 2.15
- Git
- Un abonnement Azure actif (Azure for Students suffisant)

### Déploiement Azure (Terraform)

```bash
git clone https://github.com/layassance/Projet-Cyna.git
cd Projet-Cyna/terraform
terraform init
terraform plan
terraform apply
```

> **Note région** : l'abonnement Azure for Students utilisé est restreint à **Poland Central** par la politique Azure "Allowed resource deployment regions". Les ressources Azure sont donc déployées dans cette région, bien que le projet soit conceptuellement ancré à Genève et Paris.

### Configuration des serveurs (Ansible)

```bash
cd ../ansible
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```

Les secrets (credentials, clés API) sont chiffrés via **Ansible Vault** et ne sont jamais stockés en clair dans ce dépôt.

### Déploiement de la stack Docker SOC

```bash
cd ../docker
docker compose up -d
```

Accès au dashboard Wazuh : `https://[IP-SOC]:443`  
*(Accessible uniquement depuis le poste admin — 10.0.10.10 — conformément aux règles de filtrage.)*

---

## Sécurité

### Principe du moindre privilège

- VLAN 40 (Paris) : accès aux agents Wazuh (1514/1515) autorisé, dashboard Wazuh (443) **bloqué**
- Interface d'administration pfSense : accessible **uniquement** depuis 10.0.10.10 (poste admin)
- SSH sur tous les serveurs Linux : **clé uniquement**, authentification par mot de passe désactivée
- Accès root SSH : **désactivé** sur tous les serveurs

### Segmentation réseau

Chaque zone (Management, Serveurs, SOC/Sécu, Utilisateurs, PRA, DMZ) est isolée par des règles de filtrage strictes documentées dans le DAT (Partie 2.3). La règle par défaut sur chaque interface est **DENY ALL**.

### Hardening

Durcissement appliqué via Ansible (rôle `common`) sur base **CIS Benchmark Ubuntu** et référentiel **ANSSI** :
- Désactivation des services inutiles
- Configuration SSH sécurisée
- Mises à jour de sécurité automatiques (`unattended-upgrades`)
- Pare-feu UFW configuré
- `fail2ban` installé

---

## Équipe

| Membre | Rôle dans le projet | Sections DAT |
|---|---|---|
| **Yacine OUISSA** | Infrastructure (VNet, VLAN, pfSense, AD, Azure) | 1.1, 2.1, 2.2 |
| **Oliver LI** | Sécurité (politique, SCA, tests nmap/ZAP) | 1.2, 4.1, 5.x |
| **Mazigh HAMZI** | DevOps (Terraform, Ansible, Docker, monitoring) | 3.x, 4.3, 6.x |
| **Amine BENTERKI** | Administration postes & équipements utilisateurs | 1.1 |

---

## Statut du projet

| Composant | Statut |
|---|---|
| Segmentation VLAN Genève (3 VLAN) | ✅ Opérationnel |
| pfSense Genève (règles + WireGuard) | ✅ Opérationnel |
| AD Genève — forêt cyna.local | ✅ Opérationnel |
| AD Paris — DC additionnel | 🔄 En cours |
| WireGuard Genève ↔ Paris | 🔄 En cours |
| Stack Docker SOC (Wazuh + Zabbix) | ✅ Opérationnel |
| Agents Wazuh déployés | ✅ 5 agents actifs (1 jamais connecté) |
| Alerting Wazuh par e-mail | ✅ Fonctionnel |
| Azure VNet + NSG (Poland Central) | ✅ Déployé |
| VM veeam-wsus (Azure PRA) | ✅ Déployée |
| VM web-azure (Azure DMZ) | ✅ Déployée |
| VNet Gateway (VPN on-premise ↔ Azure) | ⏳ À déployer |
| Tests nmap / OWASP ZAP | ✅ Réalisés |
| IaC Terraform (Azure) | ✅ Fonctionnel |
| Ansible hardening | ✅ Déployé |

---

## Dette technique connue

- **Pas de redondance des pare-feu** : un seul pfSense par site — panne = coupure totale du site
- **Wazuh en instance unique** : pas de haute disponibilité ni réplication OpenSearch
- **VM web-azure non supervisée par Wazuh** : aucun lien de supervision entre Azure-DMZ et le SOC de Genève
- **Hyperviseurs hétérogènes** (Hyper-V + VMware Workstation) : contrainte matérielle de lab, à consolider en production
- **Région Azure imposée** : Poland Central (politique Azure for Students), non représentative de la localisation cible

---
