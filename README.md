# Anthos for federation setup blueprint

This repository contains blueprints to construct the infrastructure for federation
using Anthos. The accompanying blueprint document covers how this architecture
can be used for the purposes of enterprise federated learning. Refer to the assets
in each folder of this repository for more details.

* [Governance and policy management](acm)
* [Setting up the federation server side architecture](server-iac)
* [Setting up the federation client side architecture](client-iac)

## Requirements

Below is a list of requirements that will need to be satisfied before beginning the installation.

- This setup assumes the user is a member of the Organization Admin role.
- While this setup can be extended to Anthos Kubernetes clusters running on premises or on other public clouds, currently the setup assumes Google managed Google Kubernetes Engine (GKE) clusters.
- A billing account with sufficient quota is required.
- Terraform, bash, gcloud and kubectl are required. For gcloud, the CLI user needs to be authenticated. Terraform version should be >= 0.14
- In order to configure Anthos Config Management, a hosted git repository (on Github) dedicated for this purpose is required.

## Understanding the repository structure

This repository has the following folders.

* [Governance and policy management](acm)

  This folder contains the policies that govern the participating clusters, both
  client and server clusters. The clusters that participate in federation use
  Anthos Config Management for their management configuration. Since Anthos Config Management uses a git repository to retrieve and synchronize cluster configuration,
  you will need to create a separate repository for this purpose using the files
  in this folder.

* [Setting up the federation server side architecture](server-iac)

  This folder contains the Terraform code necessary to setup the server side
  architecture.

* [Setting up the federation client side architecture](client-iac)

  This folder contains the Terraform code necessary to setup the client side
  architecture.

## Getting started

- Identify or create a Google Cloud Admin project. This project is where the terraform state will be stored
- Create a Google Cloud service account to run the terraform code for this setup.
  Make sure to download the key and store it in a safe location. Setup your workstation,
  to use these credentials to execute the terraform code.
- Create (or choose) a Google Cloud storage bucket that the service account has read/write access to. This will be used as the backend for terraform state.
- Review the `terraform.tfvars` file in the `client-iac` and `server-iac` folders
  and replace variables appropriately


## Setting up the server

Edit the `terraform.tfvars` file in the `server-iac` folder to set the values for the following variables:

1. project_id: Your Google cloud project ID that will serve as the admin project
2. region: Region where you would like the cluster and other resources to be created in
3. zones: Select one or more zones in the region
4. server_cluster_node_count: Number of nodes the cluster should be created with
5. acm_repo_location: Make sure to point this to the git repository that you
   create for Anthos Config Management
6. acm_branch: The branch of the repository to sync from, defaulted to 'main'

```
cd iac-server
terraform init
terraform plan -out terraform.out
terraform apply terraform.out --auto-approve
```
## Onboarding a client

Clients will be onboarded independent of other clients and therefore the
`client-iac` folder should be hosted as an indepedent repository making it easier
to distribute the necessary terraform code needed to onboard a new client.

Edit the `terraform.tfvars` file in the `client-iac` folder (to be hosted as a separate repository upon go live) to set the values for the following variables:

Rest of the README is TO-DO

