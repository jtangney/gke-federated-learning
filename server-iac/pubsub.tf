module "pubsub" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 1.8"

  topic      = "tffe-topic"
  project_id = var.project_id
}