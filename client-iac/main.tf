terraform {
  required_version = ">=1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.82.0, <4.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.82.0, <4.0.0"
    }
  }
  backend "gcs" {
    bucket = "jtg-db-client1-tfstate"
    // prefix = ""
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}