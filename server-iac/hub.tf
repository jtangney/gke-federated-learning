// module "hub-server" {
//   source           = "terraform-google-modules/kubernetes-engine/google//modules/hub"
//   project_id       = data.google_client_config.current.project

//   cluster_name     = module.server-cluster.name
//   location         = module.server-cluster.location
//   cluster_endpoint = module.server-cluster.endpoint
//   gke_hub_membership_name = "server"
//   gke_hub_sa_name = "server"
// }

// module "hub-server" {
//   source           = "terraform-google-modules/kubernetes-engine/google//modules/hub"
//   project_id       = data.google_client_config.current.project

//   cluster_name     = data.terraform_remote_state.infra.outputs.server_cluster_name
//   location         = data.terraform_remote_state.infra.outputs.server_cluster_location
//   cluster_endpoint = data.terraform_remote_state.infra.outputs.server_cluster_endpoint
//   gke_hub_membership_name = "server"
//   gke_hub_sa_name = "server"
// }

// resource "google_gke_hub_membership" "source-cluster-hub-membership" {
//   membership_id = "${module.kubernetes-engine.location}-${module.kubernetes-engine.name}"
//   project       = var.project_id
//   provider      = google-beta

//   authority {
//     issuer = "https://container.googleapis.com/v1/${module.kubernetes-engine.cluster_id}"
//   }

//   endpoint {
//     gke_cluster {
//       resource_link = "//container.googleapis.com/${module.kubernetes-engine.cluster_id}"
//     }
//   }
// }

resource "google_gke_hub_membership" "hub-server" {
  membership_id = "${module.server-cluster.name}"
  project       = var.project_id
  provider      = google-beta

  authority {
    issuer = "https://container.googleapis.com/v1/${module.server-cluster.cluster_id}"
  }

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.server-cluster.cluster_id}"
    }
  }
}