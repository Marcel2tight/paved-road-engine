resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.region

  deletion_protection = var.deletion_protection

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  networking_mode = "VPC_NATIVE"

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  network_policy {
    enabled = var.enable_network_policy
  }

  resource_labels = var.labels
}

resource "google_container_node_pool" "this" {
  name     = var.node_pool_name
  location = var.region
  cluster  = google_container_cluster.this.name

  node_count = var.node_count

  node_config {
    machine_type    = var.machine_type
    service_account = var.service_account_email
    oauth_scopes    = var.oauth_scopes
    tags            = var.tags
    labels          = var.labels

    dynamic "shielded_instance_config" {
      for_each = var.enable_shielded_nodes ? [1] : []
      content {
        enable_secure_boot          = true
        enable_integrity_monitoring = true
      }
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
