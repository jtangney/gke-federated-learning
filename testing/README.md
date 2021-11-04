# Testing [WIP]

## Verify firewall rules

### Setup
- For convenience, create a local variable that describes an output format for firewall rules list. This defines the set of columns
to display when listing firewall rules    
```
FWTABLE="table(
  name,
  network,
  sourceRanges.list():label=[SRC_RANGES],
  destinationRanges.list():label=[DEST_RANGES],
  allowed[].map().firewall_rule().list():label=ALLOW,
  denied[].map().firewall_rule().list():label=DENY,
  sourceTags.list():label=[SRC_TAGS],
  targetTags.list():label=[TARGET_TAGS],
  targetServiceAccounts.list():label=[TARGET_SA]
)"
```

### Test firewall rules
- Print the nodes in the cluster. The node names include the name of the node-pool. Note that the nodes 
do not have External IP addresses as this is a private cluster.  
`kubectl get nodes -o wide`

- GKE nodes receieve a label with the node-pool name. Print the nodes in the dedicated tenant node-pool.  
`kubectl get nodes -l cloud.google.com/gke-nodepool=fedlearn-pool`

- Print any firewall rules with 'ssh' in the name, excluding the default network. You see that there is an explicit 'allow ssh' firewall rule 
that targets any node with the 'gke-flsilo' tag  
`gcloud compute firewall-rules list  --filter "name~ssh AND -network=default" --format $FWTABLE`

- SSH into one of the tenant nodes.  
`gcloud compute ssh --tunnel-through-iap $(kubectl get nodes -l cloud.google.com/gke-nodepool=fedlearn-pool -o jsonpath='{.items[0].metadata.name}')`

- Make a request to a website. The request times out.   
`curl -i -m 10 example.com`

- Exit the ssh session  
`exit`

- Print any firewall rules with 'ssh' in the name. You see that there is an explicit 'allow ssh'
firewall rule for the network.  
`gcloud compute firewall-rules list --filter "deny~all"`


## Verify Anthos Service Mesh auth
Run some tests to verify auth behaviour of your Anthos Service Mesh

### Setup
#### Deploy an example tenant service 
- deploy a simple 'hello world' service to the tenant 'fedlearn' namespace  
`kubectl apply -f ./testing/hello-service.yaml -n fedlearn`

- The tenant namespace is enabled for Istio injection. Verify the pods have an istio-proxy container  
`kubectl -n fedlearn get pods -l app=hello -o jsonpath='{.items..spec.containers[*].name}'`

- Verify that the tenant pods are all hosted on nodes in the dedicated tenant node-pool  
`kubectl get pods -o wide -n fedlearn`

### Verify failed PeerAuthentication
#### Deploy a test pod that does not have an Istio proxy
- deploy test pod to the default namespace. You use this test pod to perform requests against the service in the tenant namespace.  
`kubectl apply -f ./testing/test.yaml -n default`

- wait for the pod to be ready  
`kubectl wait --for=condition=Ready pod -l app=test -n default`

- The default namespace is not enabled for Istio injection. Verify the pod does not have an istio-proxy container  
`kubectl -n default get pods -l app=test -o jsonpath='{.items..spec.containers[*].name}'`

#### Test the interation
- From the test pod in the default namespace, call the service in the tenant namespace  
```
kubectl -n default exec -it -c test \
  $(kubectl -n default get pod -l app=test -o jsonpath={.items..metadata.name}) \
  -- curl hello.fedlearn.svc.cluster.local
```

- You see a "Connection reset by peer" failure. 
- The istio-proxy in the metrics-writer pod rejects the request because the tenant namespace has STRICT PeerAuthentication policy. Only authenticated requests are allowed. As the test pod is not part of the mesh (it doesn't have istio-proxy container), the request fails authentication.

### Verify failed AuthorizationPolicy
#### Deploy a test pod that does receive an Istio proxy
- deploy test pod to the testing namespace. This namespace is enabled for istio injection  
`kubectl apply -f ./testing/test.yaml -n test`

- wait for the pod to be ready  
`kubectl wait --for=condition=Ready pod -l app=test -n default`

- Verify the pod has an istio-proxy sidecar container  
`kubectl -n test get pods -l app=test -o jsonpath='{.items..spec.containers[*].name}'`

#### Test the interaction
- From the test pod in the testing namespace, call the metrics-writer-service in the tenant namespace  
```
kubectl -n test exec -it -c test \
  $(kubectl -n test get pod -l app=test -o jsonpath={.items..metadata.name}) \
  -- curl hello.fedlearn.svc.cluster.local
```

- You see an "RBAC: access denied" failure. 
- This request came from a pod within the mesh, an mTLS connection between the two istio-proxies was established, and the request was
successfully authenticated. However, the request was rejected due to AuthorizationPolicy applied to the tenant namespace. The AuthorizationPolicy
only allows requests that originated from the same namespace.

### Verify success
#### Deploy a test pod to the tenant namespace
- deploy a test pod to the tenant namespace. This namespace is enabled for istio injection   
`kubectl apply -f ./testing/test.yaml -n fedlearn`

- Verify the pod does have an istio-proxy sidecar container  
`kubectl -n fedlearn get pods -l app=test -o jsonpath='{.items..spec.containers[*].name}'`

#### Test the interaction
- From the test pod in the tenant namespace, call the service in the tenant namespace  
```
kubectl -n fedlearn exec -it -c test \
  $(kubectl -n fedlearn get pod -l app=test -o jsonpath={.items..metadata.name}) \
  -- curl hello.fedlearn.svc.cluster.local
```

- The request succeeds! You see some HTML content returned by the hello service.
- As the request originated from the mesh, the tenant service istio-proxy correctly authenticated the request. As the request originated from
within the tenant namespace, the request also passed the autthorization checks.


## Verify Anthos Service Mesh egress
Run some tests to verify egress behaviour of your Anthos Service Mesh

### Verify failed unknown destination host
The mesh is configured to only allow requests to known services (via the REGISTRY_ONLY outboundTrafficPolicy on the Sidecar resource).

- deploy a test pod to the tenant namespace. This namespace is enabled for istio injection  
`kubectl apply -f ./testing/test.yaml -n fedlearn`

- Verify the pod does have an istio-proxy sidecar container  
`kubectl -n fedlearn get pods -l app=test -o jsonpath='{.items..spec.containers[*].name}'`

- Verify that the tenant namepace has REGISTRY_ONLY outboundTrafficPolicy. Therefore egress from the mesh is only allowed to hosts that exist in the registry  
`kubectl get sidecar -n fedlearn -o jsonpath='{.items[0].spec.outboundTrafficPolicy}'`

- List the ServiceEntries (TODO: use istioctl). You see that there is a ServiceEntry that configures some external domains (example.com etc)  
`kubectl get ServiceEntry -A`

- Make a request to 'example.org'. Note that this domain is not configured in the ServiceEntries.  
```
kubectl -n fedlearn exec -it -c test \
  $(kubectl -n fedlearn get pod -l app=test -o jsonpath={.items..metadata.name}) \
  -- curl -i example.org
```

- You see a 502 error. There is no ServiceEntry for this host (it is not in the service registry) so the request is rejected

### Verify successful request to known host
- Make a request to 'example.com'. 
```
kubectl -n fedlearn exec -it -c test \
  $(kubectl -n fedlearn get pod -l app=test -o jsonpath={.items..metadata.name}) \
  -- curl -i example.com
```

- You see a successful 200 reponse, and the HTML of the page. There is a ServiceEntry for example.com
