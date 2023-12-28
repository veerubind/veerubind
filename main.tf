# Cloud Storage
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


/*
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

####  PSC Consumer Endpoint with static Internal IP
resource "google_compute_address" "endpoint-psc-ip" {
  project = var.project_id
  address_type = "INTERNAL"
  name = "endpoint-psc-ip"
  purpose = "private endpoint terminal"
  region = var.region
  subnetwork = "endpoint-subnet"
}



resource "google_compute_forwarding_rule" "dev22-psc-endpoint" {
  ip_address = google_compute_address.endpoint-psc-ip.self_link
  name = "dev22-psc-endpoint"
  network = "endpoint-vpc"
  region = var.region
  load_balancing_scheme = ""
  target = "projects/mydev-22/regions/asia-south1/serviceAttachments/producer"
}
*/

/*
####  PSC Consumer Endpoint using Internal LB and NEG, PSC connecting via LB frontend Internal IP

resource "google_compute_region_network_endpoint_group" "neg-psc-endpoint" {
  name    = "neg-psc-endpoint"
  network = "endpoint-vpc"
  subnetwork = "endpoint-subnet"
  region = var.region
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = "projects/mydev-22/regions/asia-south1/serviceAttachments/producer"
}

resource "google_compute_address" "endpoint-psc-ip" {
  project = var.project_id
  address_type = "INTERNAL"
  name = "endpoint-psc-ip"
  purpose = "Internal lb static ip"
  region = var.region
  subnetwork = "endpoint-subnet"
}

resource "google_compute_region_backend_service" "psc-ep-backend" {
  name = "psc-ep-backend"
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol = "HTTP"
  backend {
    balancing_mode = "UTILIZATION"
    group = google_compute_region_network_endpoint_group.neg-psc-endpoint.id
   }
}

resource "google_compute_region_url_map" "psc-ep-url-map" {
  name = "psc-ep-url-map"
  default_service = google_compute_region_backend_service.psc-ep-backend.id
 }

resource "google_compute_region_target_http_proxy" "psc-ep-target" {
  name = "psc-ep-target"
  url_map = google_compute_region_url_map.psc-ep-url-map.id
}

resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "proxy-subnet"
  ip_cidr_range = "10.50.50.0/26"
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = "endpoint-vpc"
}

resource "google_compute_forwarding_rule" "psc-ep-front-url" {
  ip_address = google_compute_address.endpoint-psc-ip.self_link
  name = "psc-ep-front-url"
  network = "endpoint-vpc"
  subnetwork = "endpoint-subnet"
  port_range = "80"
  region = var.region
  depends_on = [google_compute_subnetwork.proxy_subnet]
  network_tier = "PREMIUM"
  load_balancing_scheme = "INTERNAL_MANAGED"
  target = google_compute_region_target_http_proxy.psc-ep-target.id
}
  
*/


#### Log Sink with Pubsub

# cloud pub-sub topic for streaming to Log aggregator 

resource "google_pubsub_topic" "pubsub-topic" {
  name = "network-logs"
  project = var.project_id
  }


# gcp resource logs sink to pubsub topic
/*
resource "google_logging_project_sink" "network-sink-to-pubsub" {
  project     =  "mydev-22"
  name        = "network-logs-to-pubsub"
  destination = "pubsub.googleapis.com/projects/mydev-22/topics/network-logs"
  filter      = "resource.type"
  unique_writer_identity = true
}


# Because our sink uses a unique_writer, we must grant that writer access.

resource "google_project_iam_binding" "pubsub-writer-pub-sub" {
  project = "mydev-22"
  role = "roles/pubsub.admin"
  members = [
    google_logging_project_sink.network-sink-to-pubsub.writer_identity
  ]
depends_on = [google_logging_project_sink.network-sink-to-pubsub]
}

resource "google_project_iam_binding" "log-writer-pub-sub" {
  project = "mydev-22"
  role = "roles/logging.admin"
  members = [
    google_logging_project_sink.network-sink-to-pubsub.writer_identity
  ]
}
*/

resource "google_logging_project_sink" "network-sink-to-bucket" {
  project     =  "mydev-22"
  name        = "network-logs-to-bucket"
  destination = "storage.googleapis.com/veer-test-bucket-22"
  filter      = "resource.type = gcs_bucket"
  unique_writer_identity = true
}


resource "google_project_iam_binding" "pubsub-writer-bucket" {
  project = "mydev-22"
  role = "roles/storage.objectCreator"
  members = [
    google_logging_project_sink.network-sink-to-bucket.writer_identity
  ]
}


