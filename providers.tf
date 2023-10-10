provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.gcp_project_id
  region      = var.gcp_region
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

