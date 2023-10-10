variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "serviceaccount_id" {
  description = "GKE Service Account ID"
  type        = string
}

variable "region" {
  description = "GCP region where resources will be deployed"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "gcp_credentials_file" {
  description = "path to GCP credentials"
  type        = string
}
