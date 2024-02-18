resource "google_dataflow_job" "cloud_pubsub_to_cloud_pubsub" {

  provider              = google-beta
  template_gcs_path     = "gs://dataflow-templates-${var.region}/latest/Cloud_PubSub_to_Cloud_PubSub"
  name                  = "cloud-pubsub-to-cloud-pubsub"
  region                = var.region
  subnetwork            = "projects/mydev-22/regions/asia-south1/subnetworks/dataflow-subnet"
  service_account_email  = "dataflow-sa@mydev-22.iam.gserviceaccount.com"
  temp_gcs_location     = "gs://veer-dataflow-temp/temp"
  parameters            = {
    inputSubscription = "projects/mydev-22/subscriptions/network-sub-push-to-secmon"
    outputTopic = "projects/mydev-22/topics/secmon-logs"
    filterKey = "logname"
    filterValue = "projects/mydev-22/logs/cloudaudit.googleapis.com%2Fdata_access"
  }
}
