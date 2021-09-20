# GKE cluster and other resources created created in this region
region="europe-west1"
# need to be from region above. Cluster nodes created in each zone. 
zones=["europe-west1-b"]
cluster_name="flsilo"

# Anthos Config Management
# Update with your own repo, if you created one
# For simplicity, repo is assumed to be publicly accessible ('none' secret)
acm_repo_location="https://github.com/jtangney/anthos-federation"
acm_secret_type="none"
acm_branch="main"
acm_dir="acm"
