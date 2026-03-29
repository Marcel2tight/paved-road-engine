module "cloud_run_service" {
  source = "../../modules/cloud-run"

  name     = "paved-road-dev-service"
  image    = "us-docker.pkg.dev/cloudrun/container/hello"
  region   = "us-central1"
}
