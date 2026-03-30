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

module "gke_app" {
  source = "../../../modules/gke"

  cluster_name          = var.cluster_name
  node_pool_name        = var.node_pool_name
  region                = var.region
  network               = var.network
  subnetwork            = var.subnetwork
  machine_type          = var.machine_type
  node_count            = var.node_count
  service_account_email = var.service_account_email
  oauth_scopes          = var.oauth_scopes
  tags                  = var.tags
  labels                = var.labels
  deletion_protection   = var.deletion_protection
}
