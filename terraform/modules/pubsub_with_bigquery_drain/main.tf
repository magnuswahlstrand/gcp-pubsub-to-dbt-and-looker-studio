resource "google_bigquery_table" "bq_table" {
  dataset_id = var.dataset_id
  table_id   = var.topic_name

  deletion_protection = false

  schema = file("${path.cwd}/schemas/${var.topic_name}_big_query.json")
}

module "pubsub-dlq" {
  source     = "terraform-google-modules/pubsub/google"
  project_id = var.project

  topic = "${var.topic_name}_dlq"
  pull_subscriptions = [
    {
      name = "${var.topic_name}_dlq"
    }
  ]
}

module "pubsub-main" {
  source     = "terraform-google-modules/pubsub/google"
  project_id = var.project

  topic              = var.topic_name
  pull_subscriptions = []
  bigquery_subscriptions = [
    {
      name = "${var.topic_name}_to_bigquery" // required

      table               = "${var.project}.${var.dataset_id}.${google_bigquery_table.bq_table.table_id}"
      use_topic_schema    = true                 // optional
      write_metadata      = false                // optional
      drop_unknown_fields = false                // optional
      dead_letter_topic   = module.pubsub-dlq.id // optional
    }
  ]
  schema = {
    name       = "${var.topic_name}-schema"
    type       = "PROTOCOL_BUFFER"
    definition = file("${path.cwd}/schemas/${var.topic_name}.proto")
    encoding   = "JSON" # or "BINARY" if using PROTOCOL_BUFFER type
  }
}