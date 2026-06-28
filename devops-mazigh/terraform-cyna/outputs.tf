output "web_cyna_ip" {
  description = "Adresse IP du serveur WEB-CYNA"
  value       = var.web_ip
}

output "ansible_inventory_file" {
  description = "Inventaire Ansible genere par Terraform"
  value       = local_file.ansible_inventory.filename
}

output "architecture_file" {
  description = "Fichier resume de l'architecture CYNA"
  value       = local_file.architecture_summary.filename
}

output "grafana_url" {
  description = "URL de Grafana"
  value       = "http://${var.ansible_ip}:3000"
}

output "prometheus_url" {
  description = "URL de Prometheus"
  value       = "http://${var.ansible_ip}:9090"
}

output "node_exporter_url" {
  description = "URL Node Exporter WEB-CYNA"
  value       = "http://${var.web_ip}:9100/metrics"
}
