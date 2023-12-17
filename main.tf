resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
  force_destroy = false
  location      = "ASIA"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = google_kms_crypto_key.terraform_state_bucket.id
  }
  depends_on = [
    google_project_iam_member.default
  ]
}




resource "google_storage_bucket" "tf-bucket" {
  name     = "tf-state-bucket-22"
  location = "asia-south1"
}
resource "google_storage_bucket" "bucket" {
  name     = "veer-test-bucket-22"
  location = "asia-south1"
}

resource "google_storage_bucket_object" "myimage" {
  name = "hello-file"
  bucket = "veer-test-bucket-22"
  source = "hello.txt"
}
