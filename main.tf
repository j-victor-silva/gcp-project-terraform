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
  name = "terraform-topic-schema"
  type = "AVRO"
  definition = file(var.topic_schema)
}

resource "google_pubsub_topic" "topic_test" {
  name = "terraform-topic-test"

  depends_on = [google_pubsub_schema.topic_schemas]
  schema_settings {
    schema = "projects/${var.project}/schemas/${google_pubsub_schema.topic_schemas.name}"
    encoding = "JSON"
  }
  labels = {
    category = "terraform"
  }
}

resource "google_pubsub_subscription" "subscription_test" {
  name = "${google_pubsub_topic.topic_test.name}-sub"
  topic = google_pubsub_topic.topic_test.name

  depends_on = [google_pubsub_topic.topic_test]
  labels = {
    category = "terraform"
  }
}