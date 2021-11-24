module "gke" {
  # The beta-private-cluster enables beta cluster features and opinionated defaults.
  # See the module docs https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/beta-private-cluster
  # 
  # The following configuration creates a cluster that implements many of the recommendations in the GKE hardening guide
  # https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster:
  #  - private GKE cluster with authorized networks
  #  - at least 2 node pools (one default pool, plus one per tenant)
  #  - workload identity
  #  - shielded nodes  
  #  - GKE sandbox (gVisor) for the tenant nodes
  #  - Dataplane V2 (which automatically enables network policy)
  #  - secrets encryption
  source            = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  
  project_id        = var.project_id
  name              = var.cluster_name
  release_channel   = "REGULAR"
  regional          = false
  region            = var.region
  zones             = var.zones
  network           = google_compute_network.vpc.name
  subnetwork        = google_compute_subnetwork.subnet.name
  ip_range_pods     = "pods"
  ip_range_services = "services"
  
  enable_shielded_nodes = true
  enable_binary_authorization = true
  grant_registry_access = true
  
  # Encrypt cluster secrets at the application layer
  database_encryption = [{
      "key_name": module.kms.keys[var.clusterSecretsKey],
      "state": "ENCRYPTED"
  }]

  # Dataplane V2
  datapath_provider = "ADVANCED_DATAPATH"
  # automatically enabled with Dataplane V2
  network_policy = false
  
  // Private cluster nodes, public endpoint with authorized networks
  enable_private_nodes = true
  enable_private_endpoint  = false
  master_global_access_enabled = true
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  master_authorized_networks = [
    {
      display_name: "NAT IP",
      cidr_block : format("%s/32", google_compute_address.nat_ip.address)
    },
    {
      display_name: "Local IP",
      cidr_block : "${chomp(data.http.installation_workstation_ip.body)}/32"
    }
  ]
  // open ports for ASM
  add_cluster_firewall_rules = true
  // we don't want ingress into the cluster by default
  http_load_balancing = false
  
  node_pools = concat(
    // default node pool
    [{
      name = "main-pool"
      image_type = "COS_CONTAINERD"
      machine_type = var.cluster_machine_type
      min_count = 3
      max_count = 5      
      auto_upgrade = true
      enable_integrity_monitoring = true
      enable_secure_boot = true
    }],
    
    // list of tenant nodepools
    [for tenant_name, config in local.tenants: {
      name = config.tenant_nodepool_name
      image_type = "COS_CONTAINERD"
      machine_type = var.cluster_machine_type
      min_count  = 2
      max_count = 5      
      auto_upgrade = true
      enable_integrity_monitoring = true
      enable_secure_boot = true
      # enable GKE sandbox (gVisor) for tenant nodes
      sandbox_enabled = true
      # dedicated service account per tenant node pool
      service_account = format("%s@%s.iam.gserviceaccount.com", config.tenant_nodepool_sa_name, var.project_id)
    }]
  )

  # Add a label with tenant name to each tenant nodepool
  node_pools_labels = {
    for tenant_name, config in local.tenants: config.tenant_nodepool_name => {"tenant" = tenant_name}
  }

  # Add a taint based on the tenant name to each tenant nodepool
  node_pools_taints = {
    for tenant_name, config in local.tenants: config.tenant_nodepool_name => [{
      key    = "tenant"
      value  = tenant_name
      effect = "NO_EXECUTE"
    }]
  }

  depends_on = [
    module.project-services,
    google_service_account.tenant_nodepool_sa
  ]
}
