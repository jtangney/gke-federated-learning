# TensorFlow Federated on Anthos experimentation environment

This repo contains configs for setting up a simple development environment for experimenting with TensorFlow Federated on Anthos. 

**Note** that this is a very simple configuration designed for experimentation and prototyping that does NOT meet security or reliability requirements for production or even proof of concepts.

By default, the environment is configured as follows:

1. One *server* cluster that hosts the JupyterLab server for running sample scripts and notebooks and one TFF remote executor
2. `N` *client* clusters, each hosting a single TFF remote executor
3. All clusters are provisioned in a single GCP project on the `default` VPC
4. All TFF remote executors are exposed through public IP addresses. The gRPC interfaces exposed by the remote interfaces are *NOT* secured.
5. The JupyterLab server is not accessible by the public IP address
6. The clusters are registered with Anthos and configured for Anthos Configuration Management
7. The JupyterLab server and the TFF remote executors are deployed through Anthos Configuration Management


## Setting up the environment

The following instructions should be executed from Cloud Shell.

To set up the experimentation environment:

1. Update the Cloud Shell environment wit the [latest version of Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. Build the TFF remote executor and JupyterLab container images by following the instructions in the `images/README.md`
3. Update the `terraform/terraform.tfvars` file with your project ID (`project_id`) and the number of client clusters (`client_cluster_count`). You can also update the `cluster_name_prefix` variable. Note that the clusters will be named using the following naming schemas: `<prefix>-server`, `<prefix>-client-<client_number>`
4. Update the manifests in the `acm-configs\namespaces\tff` folder with your image tags and cluster names.
5. Create the environment by executing the following command from the `terraform` folder.

As noted, the JupyterLab server is not exposed through an external IP address. To access the JupyterLab server you have two options:

1. Modify the `acm-configs/namespaces/tff/jupyterlab-service.yaml` manifest to use LoadBalancer rather than ClusterIP
2. Use `kubectl` to forward the local port to the `jupyterlab` service (port 8080) on your server cluster.

```
gcloud container clusters get-credentials <your server cluster> --zone <your zone>
kubectl port-forward -n tff service/jupyterlab 8080:8080
```
