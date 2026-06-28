locals {
  machines = {
    pfsense = {
      name = "pfSense-CYNA"
      role = "Pare-feu central"
      ip   = var.pfsense_lan_ip
    }

    dc1 = {
      name = "DC1-Cyna"
      role = "Serveur interne"
      ip   = var.dc1_ip
    }

    ansible = {
      name = "ANSIBLE-CYNAA"
      role = "DevOps, Ansible, Prometheus et Grafana"
      ip   = var.ansible_ip
    }

    web = {
      name = "WEB-CYNA"
      role = "Serveur web en DMZ"
      ip   = var.web_ip
    }
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/generated/inventory.ini"

  content = <<EOT
[web]
web-cyna ansible_host=${var.web_ip} ansible_user=${var.ssh_user}
EOT
}

resource "local_file" "architecture_summary" {
  filename = "${path.module}/generated/architecture-cyna.txt"

  content = <<EOT
Projet : ${var.project_name}

Reseaux :
- LAN interne : ${var.lan_network}
- DMZ : ${var.dmz_network}
- OPT2 : ${var.opt2_network}

Passerelles pfSense :
- pfSense LAN : ${var.pfsense_lan_ip}
- pfSense DMZ : ${var.pfsense_dmz_ip}

Machines :
- pfSense-CYNA : pare-feu central
- DC1-Cyna : ${var.dc1_ip}
- ANSIBLE-CYNAA : ${var.ansible_ip}
- WEB-CYNA : ${var.web_ip}

Role DevOps :
- Terraform decrit les elements principaux de l'infrastructure.
- Terraform genere un inventaire Ansible.
- Ansible utilise cet inventaire pour administrer WEB-CYNA.
- Prometheus et Grafana supervisent WEB-CYNA.
- Grafana envoie une alerte Discord si Node Exporter devient indisponible.
EOT
}
