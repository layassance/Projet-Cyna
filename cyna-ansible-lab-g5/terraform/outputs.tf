output "web_cyna_ip" {
  value = local.web_cyna_ip
}

output "prometheus_url" {
  value = local.prometheus_url
}

output "grafana_url" {
  value = local.grafana_url
}

output "node_exporter_url" {
  value = local.node_exporter
}

output "ansible_inventory" {
  value = {
    host = var.web_host
    user = var.web_user
  }
}
