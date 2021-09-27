resource "google_gke_hub_membership" "membership" {
  membership_id = module.gke.name
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.gke.cluster_id}"
    }
  }
  provider = google-beta
}

resource "google_gke_hub_feature" "feature" {
  name = "configmanagement"
  location = "global"
  provider = google-beta
}

resource "google_gke_hub_feature_membership" "feature_member" {
  location = "global"
  feature = google_gke_hub_feature.feature.name
  membership = google_gke_hub_membership.membership.membership_id
  configmanagement {
    version = var.acm_version
    config_sync {
      git {
        sync_repo = var.acm_repo_location
        sync_branch = var.acm_branch
        policy_dir = var.acm_dir
        secret_type = var.acm_secret_type
      }
      # source_format = "hierarchy"
      source_format = "unstructured"
    }
    policy_controller {
      enabled = true
      template_library_installed = true
    }
  }
  provider = google-beta

  depends_on = [
    module.asm.asm_wait
  ]
}