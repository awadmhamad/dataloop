#locals {
  # Extract company name from the parent directory
#  company_name = basename(abspath(pathmodule()))

  # Extract environment name from the parent directory
#  environment_name = basename(abspath(pathmodule(1)))

  # Calculate bucket name and prefix
#  bucket_name = "terraform-state"
#  prefix      = "${local.company_name}/${local.environment_name}"
#}

terraform {
  backend "gcs" {
    bucket       = "dataloop-terraform-state"
    prefix       = "company1/gcp"
    credentials  = "/tmp/credentials.json"
  }
}

