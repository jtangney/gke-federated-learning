module "gke" {
  // source            = "terraform-google-modules/kubernetes-engine/google"
  source            = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  project_id        = var.project_id
  name              = var.cluster_name
  release_channel   = "REGULAR"
  regional          = false
  region            = var.region
  zones             = var.zones
  network           = google_compute_network.vpc.name
  subnetwork        = google_compute_subnetwork.subnet.name
  network_policy    = true
  ip_range_pods     = ""
  ip_range_services = ""
  create_service_account = false
  service_account   = google_service_account.cluster_default_sa.email
  enable_shielded_nodes = true
  identity_namespace = "enabled"
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  
  // Private cluster nodes, public endpoint with authorized networks
  enable_private_nodes = true
  enable_private_endpoint  = false
  master_authorized_networks = [
    {
      display_name: "NAT IP",
      cidr_block : format("%s/32", google_compute_address.nat_ip.address)
    },
    {
      display_name: "Local IP",
      cidr_block : "${chomp(data.http.myip.body)}/32"
    }
  ]
  // open port for ASM
  add_master_webhook_firewall_rules = true
  
  remove_default_node_pool = true  
  node_pools = [
    // replacement for default pool
    {
      name = "main-pool"
      image_type = "COS_CONTAINERD"
      machine_type = var.client_cluster_machine_type
      min_count  = var.client_cluster_node_count
      max_count = 10      
      auto_upgrade = true
      enable_integrity_monitoring = true
      enable_secure_boot = false
      # sandbox_type = ""
      
      # If the service account resource is reference directly, we get an error. 
      # So just construct the email address as a workaround
      service_account = format("%s@%s.iam.gserviceaccount.com", local.cluster_default_sa_name, var.project_id)
    },
    {
      name = var.fl_node_pool_name
      image_type = "COS_CONTAINERD"
      machine_type = var.client_cluster_machine_type
      min_count  = 2
      max_count = 10      
      auto_upgrade = true
      enable_integrity_monitoring = true
      enable_secure_boot = false
      # sandbox_type = "gvisor"

      # If the service account resource is reference directly, we get an error. 
      # So just construct the email address as a workaround
      service_account = format("%s@%s.iam.gserviceaccount.com", local.fl_node_pool_sa_name, var.project_id)
    }
  ]
  
  node_pools_tags = {
    all = [
      "${var.cluster_name}"
    ]
    main-pool = [
      "default-node-pool",
    ]
  }
  
  node_pools_labels = {
    all = {}
    "${var.fl_node_pool_name}" = {
      "fl-pool" = true
    }
  }

  node_pools_taints = {
    all = []
    // taint the FL pool - we use this pool exclusively for FL workloads 
    "${var.fl_node_pool_name}" = [
      {
        key    = "fl-pool"
        value  = true
        effect = "NO_EXECUTE"
      },
    ]
  }

  depends_on = [
    module.project-services,
    google_service_account.cluster_flpool_sa
  ]
}