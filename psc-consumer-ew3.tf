
####  PSC Consumer Endpoint using Internal LB and NEG, PSC connecting via LB frontend Internal IP

resource "google_compute_region_network_endpoint_group" "neg-psc-endpoint-ew3" {
  name    = "neg-psc-endpoint-ew3"
  network = "endpoint-vpc-ew3"
  subnetwork = "endpoint-subnet-ew3"
  region = var.region-ew3
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = "projects/deutsche-bank-393916/regions/europe-west3/serviceAttachments/c-30-psc"
}

resource "google_compute_address" "endpoint-psc-ip-ew3" {
  project = var.project_id
  address_type = "INTERNAL"
  name = "endpoint-psc-ip-ew3"
  purpose = "Internal lb static ip"
  region = var.region-ew3
  subnetwork = "endpoint-subnet-ew3"
}

resource "google_compute_region_backend_service" "psc-ep-backend-ew3" {
  name = "psc-ep-backend-ew3"
  region = var.region-ew3
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol = "HTTP"
  backend {
    balancing_mode = "UTILIZATION"
    group = google_compute_region_network_endpoint_group.neg-psc-endpoint-ew3.id
   }
}

resource "google_compute_region_url_map" "psc-ep-url-map-ew3" {
  name = "psc-ep-url-map-ew3"
  default_service = google_compute_region_backend_service.psc-ep-backend-ew3.id
 }

resource "google_compute_region_target_http_proxy" "psc-ep-target-ew3" {
  name = "psc-ep-target-ew3"
  url_map = google_compute_region_url_map.psc-ep-url-map-ew3.id
}

/*
resource "google_compute_subnetwork" "proxy_subnet-ew3" {
  name          = "proxy-subnet-ew3-ew3"
  ip_cidr_range = "10.60.60.0/26"
  region        = var.region-ew3
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = "endpoint-vpc-ew3"
}
*/

resource "google_compute_forwarding_rule" "psc-ep-front-url-ew3" {
  ip_address = google_compute_address.endpoint-psc-ip-ew3.self_link
  name = "psc-ep-front-url-ew3"
  network = "endpoint-vpc-ew3"
  subnetwork = "endpoint-subnet-ew3"
  port_range = "80"
  region = var.region-ew3
  # depends_on = [google_compute_subnetwork.proxy_subnet]
  network_tier = "PREMIUM"
  load_balancing_scheme = "INTERNAL_MANAGED"
  target = google_compute_region_target_http_proxy.psc-ep-target-ew3.id
}

