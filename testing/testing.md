# Testing

## Verify Anthos Service Mesh auth
Run some tests to verify auth behaviour of your Anthos Service Mesh

### Setup
#### Deploy an example tenant service 
- deploy a simple 'hello world' service to the tenant 'fedlearn' namespace  
`k apply -f ./testing/hello-service.yaml -n fedlearn`

- The tenant namespace is enabled for Istio injection. Verify the pods have an istio-proxy container  
`kubectl -n fedlearn get pods -l app=hello -o jsonpath='{.items..spec.containers[*].name}'`

- Verify that the tenant pods are all hosted on nodes in the dedicated tenant node-pool
`k get pods -o wide -n fedlearn`

### Verify failed PeerAuthentication
#### Deploy a test pod that does not have an Istio proxy
- deploy test pod to the default namespace. You use this test pod to perform requests against the service in the tenant namespace.  
`k apply -f ./testing/test.yaml -n default`

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
`k apply -f ./testing/test.yaml -n test`

- Verify the pod does have an istio-proxy sidecar container  
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
- deploy a test pod to the tenant namespace. They get an Istio sidecar injected  
`k apply -f ./testing/test.yaml -n fedlearn`

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
