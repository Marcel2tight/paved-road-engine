resource "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.region

  deletion_protection = var.deletion_protection

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

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
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
