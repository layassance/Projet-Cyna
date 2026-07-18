variable "project_name" {
  description = "Nom du projet"
  default     = "CYNA DevOps Monitoring"
}

variable "lan_network" {
  description = "Reseau interne CYNA"
  default     = "10.0.20.0/24"
}

variable "dmz_network" {
  description = "Reseau DMZ CYNA"
  default     = "10.0.10.0/24"
}

variable "opt2_network" {
  description = "Reseau utilisateur ou autre site"
  default     = "10.0.40.0/24"
}

variable "pfsense_lan_ip" {
  description = "Adresse LAN de pfSense"
  default     = "10.0.20.1"
}

variable "pfsense_dmz_ip" {
  description = "Adresse DMZ de pfSense"
  default     = "10.0.10.1"
}

variable "dc1_ip" {
  description = "Adresse IP du serveur DC1-Cyna"
  default     = "10.0.20.10"
}

variable "ansible_ip" {
  description = "Adresse IP de la machine ANSIBLE-CYNAA"
  default     = "10.0.20.30"
}

variable "web_ip" {
  description = "Adresse IP du serveur WEB-CYNA"
  default     = "10.0.10.10"
}

variable "ssh_user" {
  description = "Utilisateur SSH utilise par Ansible"
  default     = "mazigh"
}
