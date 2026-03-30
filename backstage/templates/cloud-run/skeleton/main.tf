terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "cloud_run_app" {
  source = "../../../terraform/modules/cloud-run"

  service_name          = var.service_name
  region                = var.region
  image                 = var.image
  service_account_email = var.service_account_email
  container_port        = var.container_port
  min_instance_count    = var.min_instance_count
  max_instance_count    = var.max_instance_count
  cpu                   = var.cpu
  memory                = var.memory
  ingress               = var.ingress
  allow_unauthenticated = var.allow_unauthenticated
  env_vars              = var.env_vars
  labels                = var.labels
}
