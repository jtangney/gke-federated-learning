terraform {
  required_version = ">=0.14"
  required_providers {
    google = "~> 3.5"
  }

  backend "gcs" {
    bucket = "tffe-terraform-state"
    prefix = "federated-learning-tf-state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "current" {}

data "google_project" "project" {
  project_id = var.project_id
}

output "project" {
  value = data.google_client_config.current.project
}