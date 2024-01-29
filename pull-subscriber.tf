resource "google_pubsub_topic" "network-logs" {
  name = "network-logs"
}

resource "google_pubsub_subscription" "network-logs-pull" {
  name  = "network-logs-pull"
  topic = google_pubsub_topic.network-logs.id

  labels = {
    foo = "bar"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = false
}
