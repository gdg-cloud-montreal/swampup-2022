# kcc-configs

## Description
sample description

## Usage

### Fetch the package
`kpt pkg get REPO_URI[.git]/PKG_PATH[@VERSION] kcc-configs`
Details: https://kpt.dev/reference/cli/pkg/get/

### View package content
`kpt pkg tree kcc-configs`
Details: https://kpt.dev/reference/cli/pkg/tree/

### Apply the package
```
kpt live init kcc-configs
kpt live apply kcc-configs --reconcile-timeout=2m --output=table
```
Details: https://kpt.dev/reference/cli/live/
