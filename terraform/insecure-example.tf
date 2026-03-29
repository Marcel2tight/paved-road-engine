resource "google_storage_bucket" "bad_bucket" {
  name     = "paved-road-insecure-example-12345"
  location = "US"

  uniform_bucket_level_access = false
  public_access_prevention    = "inherited"
}

resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.bad_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
