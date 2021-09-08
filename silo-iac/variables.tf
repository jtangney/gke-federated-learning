variable "org_id" {
    description = "The GCP org project ID"
    type        = string
}

variable "project_id" {
    description = "The GCP project ID"
    type        = string
}

variable "billing_account" {
    description = "The GCP Billing account"
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

variable "cluster_name_prefix" {
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
