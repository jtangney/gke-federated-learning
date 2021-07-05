module "acm-server" {
  source           = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/acm"

  project_id       = data.google_client_config.current.project
  cluster_name     = module.server-cluster.name
  location         = module.server-cluster.location
  cluster_endpoint = module.server-cluster.endpoint

  operator_path    = "config-management-operator.yaml"
  sync_repo        = var.acm_repo_location
  sync_branch      = var.acm_branch
  policy_dir       = var.acm_dir
  secret_type      = var.acm_secret_type
  create_ssh_key   = var.acm_create_ssh_key
}
