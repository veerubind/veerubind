
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

