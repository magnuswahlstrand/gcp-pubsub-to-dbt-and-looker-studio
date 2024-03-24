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
    * [ ] DBT
* [ ] Rate limit endpoints



## Resources
* https://registry.terraform.io/modules/terraform-google-modules/pubsub/google/latest
* https://medium.com/@dipan.saha/gcp-insert-records-from-pub-sub-to-bigquery-directly-2b692ff3c3e4

## Lessons learned
* Add a DLQ to the BigQuery export directly to understand why export fails

# ---------------

## Notes
How to publish a message to our topic
```
gcloud pubsub topics publish projects/$PROJECT_NAME/topics/order_created  --message='{"message":"magnus was here"}'
```
