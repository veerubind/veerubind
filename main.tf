resource "google_storage_bucket" "tf-bucket" {
  name     = "tf-state-bucket-22"
  location = "asia-south1"
}
resource "google_storage_bucket" "bucket" {
  name     = "veer-test-bucket-22"
  location = "asia-south1"
}
