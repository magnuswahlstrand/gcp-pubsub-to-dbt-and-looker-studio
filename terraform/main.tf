terraform {}


locals {
  topic_name = "order_created"
  app_name   = "order_platform"
}

provider "google" {
  project = var.project
}

# BigQuery dataset
resource "google_bigquery_dataset" "bq_dataset" {
  dataset_id = local.app_name
  location   = "EU"
}


module "orders_pubsub" {
  source = "./modules/pubsub_with_bigquery_drain"

  project    = var.project
  topic_name = "order_created"
  dataset_id = local.app_name
}
module "customers_pubsub" {
  source = "./modules/pubsub_with_bigquery_drain"

  project    = var.project
  topic_name = "customer_created"
  dataset_id = local.app_name
}

