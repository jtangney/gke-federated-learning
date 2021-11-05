# tenant-config-pkg

## Description
This package contains resources that define baseline, common configuration for a cluster tenant.
Each tenant in the cluster should have an instance of this pkg. It defines a dedicated namespace, 
service account and Istio config for the tenant.

## Usage

### Fetch the package
`kpt pkg get REPO_URI[.git]/PKG_PATH[@VERSION] tenant-pkg`
Details: https://kpt.dev/reference/cli/pkg/get/

### View package content
`kpt pkg tree tenant-pkg`
Details: https://kpt.dev/reference/cli/pkg/tree/

### Apply the package
```
kpt live init tenant-pkg
kpt live apply tenant-pkg --reconcile-timeout=2m --output=table
```
Details: https://kpt.dev/reference/cli/live/
