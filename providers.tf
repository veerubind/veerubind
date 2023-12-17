provider "google" {
  project = var.project_id
  region  = var.region
}
terraform {
  backend "gcs" {
    bucket = "tf-state-bucket-22"
    prefix = "terraform/state"
  }
}
