variable "project_id" {
    description = "The GCP project ID"
    type        = string
}

variable "region" {
    description = "The region for  clusters"
    type        = string
}

variable "zones" {
    description = "The zones for clusters"
    type        = list
}

variable "cluster_name" {
    description = "The prefix of the Kubernetes cluster name"
    type        = string
}

variable "client_cluster_node_count" {
    description = "The number of nodes in the default node pool"
    type        = string
    default     = 3
}

variable "client_cluster_machine_type" {
    description = "The machine type for a default node pool"
    type        = string
    default     = "e2-standard-4"
}

variable "acm_version" {
  description = "The location of the git repo ACM will sync to"
  default = "1.9.0"
}

variable "acm_repo_location" {
  description = "The location of the git repo ACM will sync to"
}

variable "acm_branch" {
  description = "The git branch ACM will sync to"
}

variable "acm_dir" {
  description = "The directory in git ACM will sync to"
}

variable "acm_secret_type" {
    description = "git authentication secret type"
    default     = "none"
}

variable "acm_create_ssh_key" {
    description = "Controls whether a key will be generated for Git authentication"
    default     = false
}

variable "asm_version" {
    description = "ASM version"
    default     = "1.10"
}

variable "tenant_name" {
    description = "Name of the GKE node pool dedicated to federated learning"
    default = "fedlearn"
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network"
  default = "10.0.0.0/28"
}

locals {
  tenant_nodepool_name = format("%s-pool", var.tenant_name)
  tenant_nodepool_sa_name = format("gke-%s-%s-sa", var.cluster_name, var.tenant_name)
  cluster_default_sa_name = format("gke-%s-default-sa", var.cluster_name)
}

