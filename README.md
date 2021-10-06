# [WIP] Anthos for federation setup blueprint

This repository contains a blueprint that creates Google Cloud infrastructure that is ready to participate in 
federated computations such as [federated learning](https://en.wikipedia.org/wiki/Federated_learning). 

Specifically, the blueprint creates and configures a Google Kubernetes Engine (GKE) cluster and related infrastructure
such that the cluster is ready to participate as a processing node ("silo") in federated computation. The federated
computation may involve running untrusted third party code or models, so the cluster is configured according to security
best practices, and the workers performing federated computation are isolated. The blueprint uses [Anthos](https://cloud.google.com/anthos)
features to automate and optimise the configuration and security of the cluster.

## Requirements / Caveats
- A Google Cloud project, with billing enabled and with sufficient quota is required.
- You need Owner permissions on the project
- The initial version of the blueprint creates infrastructure in Google Cloud. It can be extended to Anthos clusters running on premises or on other public clouds
- You can deploy the blueprint using Cloud Shell. If you want to execute locally you'll need Terraform, bash, gcloud and kubectl
- You use Anthos Config Management to configure your cluster. It is recommended to create a new git repository (e.g. on Github) to host cluster configs.
- You create the infastructure using Terraform. The blueprint uses a local [backend](https://www.terraform.io/docs/language/settings/backends/configuration.html). It is recommended to configure a remote backend for anything other than experimentation

## Understanding the repository structure
This repository has the following folders.

* [silo-iac](silo-iac)
  
  This folder contains the Terraform code used to create the GKE "silo" cluster and associated infrastructure.

* [configsync](configsync)
  
  This folder contains the configuration and policies that are applied to your GKE cluster by Anthos Config
  Management (ACM). It is recommended to copy this directory to a new git repository that you own.


## Deploy the blueprint
- Open Cloud Shell

- Clone this repo

- Change into the IaC dir  
  ```cd silo-iac```

- Review the `terraform.tfvars` file and replace values appropriately

- Set a Terraform environment variable for your project ID  
  ```export TF_VAR_project_id=[YOUR_PROJECT_ID]```

- Initialise Terraform  
  ```terraform init```

- Create the plan; review it so you know what's going on  
  ```terraform plan -out terraform.out```

- Apply the plan to create the cluster. Note this may take ~12 minutes to complete  
  ```terraform apply terraform.out```


##  Test
TCB