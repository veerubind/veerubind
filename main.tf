resource "google_storage_bucket" "test-bucket" {
  name     = "veer-test-bucket-22"
  location = "asia-south1"
}

resource "google_storage_bucket_object" "myimage" {
  name = "hello-file"
  bucket = "veer-test-bucket-22"
  source = "hello.txt"
  depends_on = [google_storage_bucket.test-bucket]
}

#VPC creation

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_compute_zones" "dev22-zone" {
  region  = var.region
  project = var.project_id
}

locals {
  type   = ["public", "private"]
  zones = data.google_compute_zones.dev22-zone.names
}


# VPC
resource "google_compute_network" "dev22-vpc" {
  name                            = "${var.vpcname}-vpc"
  delete_default_routes_on_create = false
  auto_create_subnetworks         = true
  routing_mode                    = "REGIONAL"
}
