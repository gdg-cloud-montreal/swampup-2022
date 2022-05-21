
# Use Cloud Deploy to deploy Microservices Applications

## Configure Delivery Pipeline in Cloud Deploy

**Step 1** Make sure the default Compute Engine service account has sufficient permissions.

Add the `clouddeploy.jobRunner` role:

export PROJECT_ID=swampup-2022

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
    --format="value(projectNumber)")-compute@developer.gserviceaccount.com \
    --role="roles/clouddeploy.jobRunner"
```

```
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
    --format="value(projectNumber)")-compute@developer.gserviceaccount.com \
    --role="roles/container.developer"
```

**Step 2**  Deploy `cloud-deploy-pipeline.yaml` in order to configure `DeliveryPipeline` resource:

```
cat cloud-deploy-pipeline.yaml
```

**Output:**
```
apiVersion: deploy.cloud.google.com/v1beta1
kind: DeliveryPipeline
metadata:
  name: swampup-2022-online-boutique
description: Online Boutique delivery pipeline
serialPipeline:
 stages:
 - targetId: swampup-2022-dev-cluster
 - targetId: swampup-2022-stg-cluster
 - targetId: swampup-2022-prod-cluster 
```


```
gcloud deploy apply --file cloud-deploy-pipeline.yaml --region=us-central1 --project=$PROJECT_ID
```

List created GKE Cluster targets:

```
gcloud deploy targets list --region=us-central1 --project=$PROJECT_ID
```
**Step 3**  Deploy `cloud-deploy-targets.yaml` file, that defines Cloud Deploy `Targets`:

We need to tell Cloud Deploy about the GKE clusters — a `cluster` is known to Cloud Deploy as a `Target` — and we provide the sequence of clusters/targets that our pipeline (DeliveryPipeline) should go through, in our case this will be "Dev", “Staging” followed by `prod`.


```
cat cloud-deploy-targets.yaml
```
**Output:**
```
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: swampup-2022-dev-cluster
requireApproval: false
gke:
  cluster: projects/swampup-2022/locations/us-central1/clusters/dev-cluster
---
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: swampup-2022-prod-cluster
requireApproval: true
gke:
  cluster: projects/swampup-2022/locations/us-central1/clusters/prod-cluster
---
apiVersion: deploy.cloud.google.com/v1
kind: Target
metadata:
  name: swampup-2022-stg-cluster
requireApproval: true
gke:
  cluster: projects/swampup-2022/locations/us-central1/clusters/stg-cluster
```

```
gcloud deploy apply --file cloud-deploy-targets.yaml --region=us-central1 --project=$PROJECT_ID
```

## Manually test application deployment by creating a Cloud Deploy `release`

Cloud Deploy uses Skaffold for manifest rendering, deployment and status checks. Scaffold let's you render `kubectl`, `helm`, `kustomize` type of files.


```
cat skaffold.yaml
```
**Output:**
```
apiVersion: skaffold/v2beta18
kind: Config
metadata:
  name: online-boutique
deploy:
  kubectl:
    manifests:
    - ./adservice.yaml
    - ./cartservice.yaml
...

Let’s test this out manually first — later we’ll update Jfrog Pipeline to automate everything end-to-end. 
Run the command below to create the initial Cloud Deploy Release to the `Dev` cluster.

```
gcloud deploy releases create initial-release-1 \
    --project=$PROJECT_ID \
    --delivery-pipeline=swampup-2022-online-boutique \
    --region=us-central1 \
```

WIP