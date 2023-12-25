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
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
}

# SUBNETS
resource"google_compute_subnetwork""dev22-subnets" {
count= 2
name="${var.name}-${local.type[count.index]}-subnetwork"
ip_cidr_range= var.ip_cidr_range[count.index]
region=var.region
network=google_compute_network.dev22-vpc.id
private_ip_google_access =true
}

# NAT ROUTER
resource "google_compute_router" "nat" {
  name    = "${var.name}-${local.type[1]}-router"
  region  = google_compute_subnetwork.dev22-subnets[1].region
  network = google_compute_network.dev22-vpc.id
}

resource "google_compute_router_nat" "nat-route" {
  name                               = "${var.name}-${local.type[1]}-router-nat"
  router                             = google_compute_router.nat.name
  region                             = google_compute_router.nat.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                             = "${var.name}-${local.type[1]}-subnetwork"
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
