# Create network endpoint
resource "google_compute_global_network_endpoint" "default" {
 global_network_endpoint_group = google_compute_global_network_endpoint_group.default.name
 fqdn                          = "www.example.com"
 port                          = 90
}

# Add network endpoint to network endpoint group
resource "google_compute_global_network_endpoint_group" "default" {
 name                  = "example-neg"
 default_port          = "90"
 network_endpoint_type = "INTERNET_FQDN_PORT"
}

/^
# Since this is an external LB it needs a SSL certificate
resource "google_compute_managed_ssl_certificate" "default" {
 name = "example-cert"

 managed {
   domains = ["example.com"]
 }
}

# Forwarding rule
resource "google_compute_global_forwarding_rule" "example" {
 name                  = "example-forwarding-rule"
 provider              = google-beta
 port_range            = "443"
 target                = google_compute_target_https_proxy.default.self_link
 ip_address            = google_compute_global_address.default.address
}

# Public IP address
resource "google_compute_global_address" "default" {
 provider      = google-beta
 name          = "example-address"
 ip_version    = "IPV4"
}

# HTTPS proxy 
resource "google_compute_target_https_proxy" "default" {
 name             = "example-proxy"
 url_map          = google_compute_url_map.default.id
 ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

# URL Map
resource "google_compute_url_map" "default" {
 name        = "example-urlmap"
 description = "Example url map"

 default_service = google_compute_backend_service.default.id
 }
*/

# Make NEG the backend
resource "google_compute_backend_service" "veer-neg-backend" {
 name          = "example-backend-service"
 port_name     = "https"
 protocol      = "HTTPS"
 backend {
   group = google_compute_global_network_endpoint_group.default.self_link
   balancing_mode = "UTILIZATION"
   capacity_scaler = "1.0"
 }
}

