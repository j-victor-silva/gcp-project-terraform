terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("projeto_gcp_credentials.json")

  project = "airy-charmer-386522"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_pubsub_topic" "topic_test" {
  name = "terraform-topic-test"

  labels = {
    category = "terraform"
  }
}

resource "google_pubsub_subscription" "subscription_test" {
  name = "${google_pubsub_topic.topic_test.name}-sub"
  topic = google_pubsub_topic.topic_test.name

  labels = {
    category = "terraform"
  }
}