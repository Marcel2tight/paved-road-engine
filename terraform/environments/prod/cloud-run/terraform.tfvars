project_id            = "imposing-fx-413205"
region                = "us-central1"
service_name          = "paved-road-prod-app"
image                 = "us-docker.pkg.dev/cloudrun/container/hello"
service_account_email = "paved-road-sa@imposing-fx-413205.iam.gserviceaccount.com"

container_port        = 8080
min_instance_count    = 1
max_instance_count    = 3
cpu                   = "1"
memory                = "512Mi"
ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
allow_unauthenticated = false

env_vars = {
  ENVIRONMENT = "prod"
  PLATFORM    = "paved-road-engine"
}

labels = {
  environment = "prod"
  managed_by  = "terraform"
  platform    = "paved-road-engine"
  security    = "hardened"
  service     = "paved-road-engine"
  owner       = "platform-team"
}
