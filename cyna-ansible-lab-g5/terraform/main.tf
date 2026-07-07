terraform {
  required_version = ">= 1.5.0"
}

locals {
  web_cyna_ip      = "10.0.10.10"
  prometheus_url   = "http://10.0.20.30:9090"
  grafana_url      = "http://10.0.20.30:3000"
  node_exporter    = "http://10.0.10.10:9100/metrics"
}
