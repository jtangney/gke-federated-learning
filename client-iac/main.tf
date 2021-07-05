terraform {
  required_version = ">=0.14"
  required_providers {
    google = "~> 3.5"
  }

  backend "gcs" {
    bucket = "tffe-terraform-state"
    prefix = "federated-learning-tf-state-client"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}