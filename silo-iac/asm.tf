module "asm" {
  source                = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  asm_version           = var.asm_version
  
  project_id            = var.project_id
  cluster_name          = module.gke.name
  location              = module.gke.location
  cluster_endpoint      = module.gke.endpoint
  enable_all            = false
  enable_cluster_roles  = true
  enable_cluster_labels = false
  enable_gcp_apis       = false
  // enable_gcp_iam_roles  = true
  enable_gcp_iam_roles  = false
  enable_gcp_components = true
  enable_registration   = false
  managed_control_plane = false
  // options               = ["envoy-access-log,egressgateways"]
  // options               = ["egressgateways"]
  // custom_overlays       = ["./custom_ingress_gateway.yaml"]
  skip_validation       = true
  outdir                = "./${module.gke.name}-outdir-${var.asm_version}"
}