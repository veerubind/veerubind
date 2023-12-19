provider "google" {
  project = var.project_id
  region  = var.region
}
terraform {
  backend "gcs" {
    bucket = "fstate-bucket-22"
    prefix = "terraform/state"
  }
}

