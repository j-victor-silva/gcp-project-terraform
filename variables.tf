variable "project" {
  default = "airy-charmer-386522"
}

variable "credentials" {
  default = "projeto_gcp_credentials.json"
}

variable "topic_schema" {
  default = "schema.proto"
}

variable "table_schema" {
  default = "table_schema.json"
}

variable "topic_schema_name" {
  default = "terraform-topic-schema"
}

variable "topic_name" {
  default = "terraform-topic"
}

variable "topic_dead_message_name" {
  default = "terraform-topic-dead-message"
}

variable "dataset_name" {
  default = "streaming-dataset"
}

variable "table_name" {
  default = "streaming-table"
}