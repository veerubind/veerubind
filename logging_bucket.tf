resource "google_logging_project_bucket_config" "basic" {
    project    = var.project_id
    location  = "global"
    retention_days = 30
    bucket_id = "veer-logging"
}
