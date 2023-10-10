provider "google" {
  credentials = file(var.gcp_credentials_file)
}

resource "google_service_account" "cluster_service_account" {
  account_id   = var.serviceaccount_id
  project      = var.project_id
  display_name = "Dataloop test service account"
  
}

resource "google_container_cluster" "dataloop_cluster" {
  name                = var.cluster_name
  location            = "us-central1"
  project             = var.project_id  
  deletion_protection = false

  node_config {
    preemptible     = true
    machine_type    = "e2-micro"
    disk_type       = "pd-standard"
    disk_size_gb    = 20
    service_account = google_service_account.cluster_service_account.email  
  }
  
  initial_node_count       = 1
}

data "google_client_config" "current" {
}

provider "kubernetes" {
#  config_context_cluster = "dataloop-cluster"
#  load_config_file       = false
  cluster_ca_certificate = base64decode("${google_container_cluster.dataloop_cluster.master_auth.0.cluster_ca_certificate}")
  host                   = "https://${google_container_cluster.dataloop_cluster.endpoint}"
  token                  = data.google_client_config.current.access_token
#  client_certificate     = base64decode("${google_container_cluster.dataloop_cluster.master_auth.0.client_certificate}")
#  client_key             = base64decode("${google_container_cluster.dataloop_cluster.master_auth.0.client_key}")
}

resource "kubernetes_namespace" "services" {
  metadata {
    name = "services"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.services.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
        }
      }
    }
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }
      
      spec {
	container {
          name  = "prometheus"
          image = "prom/prometheus:v2.30.3"
          port {
            container_port = 9090
          }
         }
       }
     }
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:latest"
          port {
            container_port = 3000
          }
        }
       }
    }
  }
}
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.services.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.nginx.spec[0].template[0].metadata[0].labels.app
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.grafana.spec[0].template[0].metadata[0].labels.app
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}
