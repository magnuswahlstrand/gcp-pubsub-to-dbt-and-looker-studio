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

  schema = jsonencode([
    {
      "name" : "subscription_name",
      "type" : "STRING",
      "mode" : "REQUIRED"
    },
    {
      "name" : "message_id",
      "type" : "STRING",
      "mode" : "REQUIRED"
    },
    {
      "name" : "publish_time",
      "type" : "TIMESTAMP",
      "mode" : "REQUIRED"
    },
    {
      "name" : "data",
      "type" : "JSON", // Use BYTES if the data is binary
      "mode" : "REQUIRED"
    },
    {
      "name" : "attributes",
      "type" : "JSON", // Use JSON if the attributes are in JSON format
      "mode" : "REQUIRED"
    }
  ])
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
      use_topic_schema    = false                    // optional
      write_metadata      = true                   // optional
      drop_unknown_fields = false                   // optional
    }
  ]
  schema = {
    name       = "${local.topic_name}-schema"
    type       = "PROTOCOL_BUFFER"
    definition = file("${path.module}/schemas/${local.topic_name}.proto")
    encoding   = "JSON"  # or "BINARY" if using PROTOCOL_BUFFER type
  }

}
