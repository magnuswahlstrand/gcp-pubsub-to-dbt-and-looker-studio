variable "project" {
  type        = string
  description = "The GCP project ID where resources will be created."
}

variable "topic_name" {
  type        = string
  description = "The base name for the Pub/Sub topic and associated resources."
}

variable "dataset_id" {
  type        = string
  description = "The ID of the BigQuery dataset to create the output table in"
}