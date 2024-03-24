# Data platform in GCP using PubSub and DBT

* Go
* Google Cloud Platform
    * Cloud Functions
    * PubSub
    * BigQuery
* DBT
* Looker Studio
* Terraform

## Todos

* [ ] Terraform
    * [x] PubSub
    * [x] BigQuery
    * [ ] GCP Service account for DBT
    * [ ] DBT
        * [ ] DBT project
* [ ] Rate limit endpoints

## Resources

* https://registry.terraform.io/modules/terraform-google-modules/pubsub/google/latest
* https://medium.com/@dipan.saha/gcp-insert-records-from-pub-sub-to-bigquery-directly-2b692ff3c3e4
* https://registry.terraform.io/providers/dbt-labs/dbtcloud/latest/docs/guides/1_getting_started

## Lessons learned

* Add a DLQ to the BigQuery export directly to understand why export fails
* DBT
    * Can't use the API (and terraform) with the free version. You can probably get quite far setting up the project
      manually, or taking advantage of the trial period.

# ---------------

# How tos

## DBT setup

If you don't have a paid account, you can't use the API, so we can't use Terraform. We can still set up the project manually. 
We need the GCP service account with JobUser and DataEditor roles. Terraform will set that up, then:

1. Go to GCP console and create a new JSON key for the service accounts
2. Go to DBT and create a new project
3. Go to the project settings and add the service account key
4. Profit

## Notes

How to publish a message to our topic

```
gcloud pubsub topics publish projects/$PROJECT_NAME/topics/order_created  --message='{"message":"magnus was here"}'
```
