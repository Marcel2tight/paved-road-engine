resource "google_storage_bucket" "bad_bucket" {
  name     = "paved-road-insecure-example-bucket"
  location = "US"

  uniform_bucket_level_access = false
}
