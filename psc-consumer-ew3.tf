
####  PSC Consumer Endpoint using Internal LB and NEG, PSC connecting via LB frontend Internal IP

resource "google_compute_region_network_endpoint_group" "neg-psc-endpoint" {
  name    = "neg-psc-endpoint"
  network = "endpoint-vpc-ew3"
  subnetwork = "endpoint-subnet-ew3"
  region = var.region-ew3
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = "projects/deutsche-bank-393916/regions/europe-west3/serviceAttachments/c-30-psc"
}

resource "google_compute_address" "endpoint-psc-ip" {
  project = var.project_id
  address_type = "INTERNAL"
  name = "endpoint-psc-ip"
  purpose = "Internal lb static ip"
  region = var.region-ew3
  subnetwork = "endpoint-subnet-ew3"
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

/*
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "proxy-subnet-ew3"
  ip_cidr_range = "10.60.60.0/26"
  region        = var.region-ew3
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = "endpoint-vpc-ew3"
}
*/

resource "google_compute_forwarding_rule" "psc-ep-front-url" {
  ip_address = google_compute_address.endpoint-psc-ip.self_link
  name = "psc-ep-front-url"
  network = "endpoint-vpc-ew3"
  subnetwork = "endpoint-subnet-ew3"
  port_range = "80"
  region = var.region-ew3
  # depends_on = [google_compute_subnetwork.proxy_subnet]
  network_tier = "PREMIUM"
  load_balancing_scheme = "INTERNAL_MANAGED"
  target = google_compute_region_target_http_proxy.psc-ep-target.id
}

