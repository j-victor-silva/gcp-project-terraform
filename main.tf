terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)

  project = var.project
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_pubsub_schema" "topic_schemas" {
  name       = var.topic_schema_name
  type       = "PROTOCOL_BUFFER"
  definition = file(var.topic_schema)
}

resource "google_pubsub_topic" "main_topic" {
  name = var.topic_name

  depends_on = [google_pubsub_schema.topic_schemas]
  schema_settings {
    schema   = "projects/${var.project}/schemas/${google_pubsub_schema.topic_schemas.name}"
    encoding = "JSON"
  }
  labels = {
    category = "terraform"
  }
}

resource "google_pubsub_topic" "dead_message_topic" {
  name = var.topic_dead_message_name

  labels = {
    category = "terraform"
  }
}

resource "google_pubsub_subscription" "main_sub" {
  name  = "${google_pubsub_topic.main_topic.name}-push-sub"
  topic = google_pubsub_topic.main_topic.name

  depends_on = [google_pubsub_topic.main_topic, google_bigquery_table.landing]

  bigquery_config {
    table               = "${google_bigquery_table.landing.project}.${google_bigquery_table.landing.dataset_id}.${google_bigquery_table.landing.table_id}"
    use_topic_schema    = true
    drop_unknown_fields = true
  }
  labels = {
    category = "terraform"
  }
}

resource "google_pubsub_subscription" "dead_message_sub" {
  name  = "${google_pubsub_topic.dead_message_topic.name}-sub"
  topic = google_pubsub_topic.dead_message_topic.name

  depends_on = [google_pubsub_topic.dead_message_topic]

  labels = {
    category = "terraform"
  }
}

resource "google_bigquery_dataset" "raw" {
  dataset_id                  = var.dataset_name
  friendly_name               = var.dataset_name
  description                 = "Dataset onde irá conter a tabela de streaming"
  location                    = "US"
}

resource "google_bigquery_table" "landing" {
  dataset_id          = google_bigquery_dataset.raw.dataset_id
  table_id            = "landing"

  time_partitioning {
    type = "DAY"
  }

  schema = file(var.table_schema)
}

resource "google_storage_bucket" "main_bucket" {
  name          = "terraform-docassure-pubsub-bucket"
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_object" "insert_topic_schema" {
  name   = "topic_schema/${var.topic_schema}"
  source = var.topic_schema
  bucket = google_storage_bucket.main_bucket.name
}

resource "google_storage_bucket_object" "insert_table_schema" {
  name   = "table_schema/${var.table_schema}"
  source = var.table_schema
  bucket = google_storage_bucket.main_bucket.name
}
