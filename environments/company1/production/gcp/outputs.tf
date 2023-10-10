output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.dataloop_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = google_container_cluster.dataloop_cluster.endpoint
}

output "nginx_load_balancer_ip" {
  value       = kubernetes_service.nginx.status.0.load_balancer.0.ingress[0].ip
  description = "External IP address of the NGINX Load Balancer"
}

output "grafana_load_balancer_ip" {
  value       = kubernetes_service.grafana.status.0.load_balancer.0.ingress[0].ip
  description = "External IP address of the Grafana Load Balancer"
}

