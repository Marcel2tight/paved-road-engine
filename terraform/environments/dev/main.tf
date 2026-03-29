module "cloud_run_service" {
  source = "./terraform/modules/cloud-run"

  name   = "local-test-service"
  image  = "us-docker.pkg.dev/cloudrun/container/hello"
  region = "us-central1"
}
