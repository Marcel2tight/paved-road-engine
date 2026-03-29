resource "google_cloud_run_v2_service" "service" {
  name     = var.name
  location = var.region

  template {
    containers {
      image = var.image

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }
  }

  labels = {
    managed-by  = "terraform"
    paved-road  = "true"
  }
}

output "service_url" {
  value = google_cloud_run_v2_service.service.uri
}
