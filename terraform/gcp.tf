module "service_account_for_dbt" {
  source        = "terraform-google-modules/service-accounts/google"
  project_id    = var.project
  names         = ["dbt-service-account"]
  project_roles = [
    "${var.project}=>roles/bigquery.jobUser",
    "${var.project}=>roles/bigquery.dataEditor",
  ]
}
