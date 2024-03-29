variable "project_id" {
  type        = string
  description = "The Google Cloud Project Id"
  default        = "mydev-22"
}

variable "region" {
  type    = string
  description  = "Region for this infrastructure."
  default = "asia-south1"
}

variable "region-ew3" {
  type    = string
  description  = "Region for psc test."
  default = "europe-west3"
}

variable "vpcname" {
  type           = string
  description  = "Name for this infrastructure"
  default       = "dev22"
}

variable"ip_cidr_range" {
type=list(string)
description="List of The range of internal addresses that are owned by this subnetwork."
default=["10.10.10.0/29", "10.10.20.0/29"]
}

# variable "project" {
#  description = "The project ID to create the resources in."
#  type        = string
# }

# variable "zone" {
#  description = "The availability zone to create the sample compute instances in. Must within the region specified in 'var.region'"
#  type        = string
# }

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "Name for the load balancer forwarding rule and prefix for supporting resources."
  type        = string
  default     = "http-multi-backend"
}

variable "enable_ssl" {
  description = "Set to true to enable ssl. If set to 'true', you will also have to provide 'var.custom_domain_name'."
  type        = bool
  default     = false
}

variable "enable_http" {
  description = "Set to true to enable plain http. Note that disabling http does not force SSL and/or redirect HTTP traffic. See https://issuetracker.google.com/issues/35904733"
  type        = bool
  default     = true
}

variable "static_content_bucket_location" {
  description = "Location of the bucket that will store the static content. Once a bucket has been created, its location can't be changed. See https://cloud.google.com/storage/docs/bucket-locations"
  type        = string
  default     = "US"
}

variable "create_dns_entry" {
  description = "If set to true, create a DNS A Record in Cloud DNS for the domain specified in 'custom_domain_name'."
  type        = bool
  default     = false
}

variable "custom_domain_name" {
  description = "Custom domain name."
  type        = string
  default     = ""
}

variable "dns_managed_zone_name" {
  description = "The name of the Cloud DNS Managed Zone in which to create the DNS A Record specified in var.custom_domain_name. Only used if var.create_dns_entry is true."
  type        = string
  default     = ""
}

variable "dns_record_ttl" {
  description = "The time-to-live for the load balancer A record (seconds)"
  type        = string
  default     = 60
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the resources. The key is the label name and the value is the label value."
  type        = map(string)

  default = {}
}

variable "activate_apis" {
  description = "activate_apis"
  type   =   list(string)
}
