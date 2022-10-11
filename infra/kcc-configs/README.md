# kcc-configs

## Description
kcc autopilot config bootstrap

## Usage

Create Config Controller instance

1. Set Environment Variables
```
export PROJECT_ID=swampup-2022  
export REGION=us-central1
gcloud config set project ${PROJECT_ID}
```

2. Create Config Controller instance
```
gcloud alpha anthos config controller create kcc-controller --full-management --location us-central1
```

gcloud iam service-accounts create gmp-demo


3. Give Config Controller permissions to create resources
```
export SA_EMAIL="$(kubectl get ConfigConnectorContext -n config-control -o jsonpath='{.items[0].spec.googleServiceAccount}' 2> /dev/null)"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member "serviceAccount:${SA_EMAIL}" --role roles/owner
```

4. Deploy the infrastructure
```
kpt live init -n config-control
kpt live apply
```


### Fetch the package

`kpt pkg get https://github.com/cartyc/swampup-2022.git/infra/kcc-configs kcc-configs`
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



## Cleanup

Delete Kubernetes clusters as it will enquire cost both for GKE and GMP.

```
gcloud container clusters delete  krmapihost-kcc-controller --region us-central1
```
