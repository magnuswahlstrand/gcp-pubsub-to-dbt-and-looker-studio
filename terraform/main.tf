terraform {
}

locals {
  topic_name = "order_created"
  app_name   = "order_platform"
}

provider "google" {
  project = var.project
}

# BigQuery dataset
resource "google_bigquery_dataset" "bq_dataset" {
  dataset_id = "${local.app_name}_${local.topic_name}"
  #  friendly_name               = "Dataset for Pub/Sub messages"
  #  description                 = "A dataset that stores Pub/Sub messages"
  location   = "EU"
  #  default_table_expiration_ms = 3600000  # Optional: 1 hour
}
#
#
## BigQuery table
resource "google_bigquery_table" "bq_table" {
  dataset_id = google_bigquery_dataset.bq_dataset.dataset_id
  table_id   = "${local.app_name}_table"

  deletion_protection = false

  schema = file("${path.module}/schemas/${local.topic_name}_output.json")
#  schema = jsonencode([
#    {
#      "name" : "message",
#      "type" : "JSON",
#      "mode" : "NULLABLE"
#    }
#  ])
}

module "pubsub-dlq" {
  source     = "terraform-google-modules/pubsub/google"
  project_id = var.project

  topic              = "${local.topic_name}_dlq"
  pull_subscriptions = [
    {
      name = "${local.topic_name}_dlq"
    }
  ]
}

module "pubsub-main" {
  source     = "terraform-google-modules/pubsub/google"
  project_id = var.project

  topic                  = "${local.topic_name}"
  pull_subscriptions     = []
  bigquery_subscriptions = [
    {
      name = "pubsub_to_big_query_${local.topic_name}"              // required

      table               = "${var.project}.${google_bigquery_dataset.bq_dataset.dataset_id}.${google_bigquery_table.bq_table.table_id}"
      use_topic_schema    = true                    // optional
      write_metadata      = false                   // optional
      drop_unknown_fields = false                   // optional
      dead_letter_topic   = module.pubsub-dlq.id // optional
    }
  ]
  schema = {
    name       = "${local.topic_name}-schema"
    type       = "PROTOCOL_BUFFER"
    definition = file("${path.module}/schemas/${local.topic_name}.proto")
    encoding   = "JSON"  # or "BINARY" if using PROTOCOL_BUFFER type
  }

}
