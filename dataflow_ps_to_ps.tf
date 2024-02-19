resource "google_dataflow_job" "cloud_pubsub_to_cloud_pubsub" {

  provider               = google-beta
  template_gcs_path      = "gs://dataflow-templates-${var.region}/latest/Cloud_PubSub_to_Cloud_PubSub"
  name                   = "cloud-pubsub-to-cloud-pubsub"
  region                 = "europe-west3"
  network                = "projects/mydev-22/global/networks/dataflow-nw"
  subnetwork             = "regions/europe-west3/subnetworks/dataflow-subnet-ew3"
  ip_configuration       = "WORKER_IP_PRIVATE"
  service_account_email  = "dataflow-sa@mydev-22.iam.gserviceaccount.com"
  temp_gcs_location      = "gs://veer-dataflow-temp/temp"
  machine_type           =  "n1-standard-4"
  max_workers            = "2"
  parameters             = {
    inputSubscription = "projects/mydev-22/subscriptions/network-sub-push-to-secmon"
    outputTopic = "projects/mydev-22/topics/secmon-logs"
    filterKey = "logname"
    filterValue = "projects/mydev-22/logs/cloudaudit.googleapis.com%2Fdata_access"
  }
}

resource "google_service_account_iam_binding" "terraform_caller_impersonate_dataflow_worker" {
  service_account_id = "dataflow-sa@mydev-22.iam.gserviceaccount.com"
  role = "roles/iam.serviceAccountUser"

  members = [
      "serviceAccount:github-sa@mydev-22.iam.gserviceaccount.com"
  ]
}
