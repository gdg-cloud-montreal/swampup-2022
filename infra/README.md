# swampup2022-infrastucture

This repository sets up an infrastructure environment on GCP in order to deploy Microservices Application.

It creates custom  VPC, with subnets and deploy's GKE Autopilot Clusters.

## Setup Dev, Staging and Production GKE Autopilot Clusters

**Step 1**  [Create a Google Cloud Platform project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) or use an existing project. Set the `PROJECT_ID` environment variable and ensure the Google Kubernetes Engine and Cloud Operations APIs are enabled.

```
export PROJECT_ID=swampup-2022  
export REGION=us-central1
gcloud config set project ${PROJECT_ID}
```

**Step 2** Create a [custom](https://cloud.google.com/vpc/docs/using-vpc#create-custom-network) mode network (VPC) using gcloud command with following parameters:

  * Network name: `custom-vpc`
  * Subnet mode: `custom`
  * Bgp routing mode: `regional`
  * MTUs: `default`

```
gcloud compute networks create custom-vpc \
    --subnet-mode=custom \
    --bgp-routing-mode=regional \
    --mtu=1460
```


**Step 3:** Create firewall rules `default-allow-internal` and `default-allow-ssh`:

```
gcloud compute firewall-rules create custom-allow-tcp-ssh-icmp --network custom-vpc --allow tcp:22,tcp:3389,icmp
gcloud compute firewall-rules create allow-internal --network custom-vpc --allow tcp,udp,icmp --source-ranges 10.128.0.0/22
```

Reference: https://cloud.google.com/kubernetes-engine/docs/concepts/firewall-rules


**Step 4** Create `dev`, `staging`, `prod` subnets for custom-vpc


```
env  |   subnet      | pod range       | srv range       | kubectl api range
dev  | 10.128.0.0/23 | 10.0.0.0/16     | 10.100.0.0/23   | 172.16.0.0/28
staging  | 10.129.0.0/23 | 10.2.0.0/16     | 10.100.2.0/23   | 172.16.0.16/28
prod | 10.130.0.0/23 | 10.4.0.0/16     | 10.100.4.0/23   | 172.16.0.32/28
```

```
gcloud compute networks subnets create gke-dev-cluster-subnet \
--network custom-vpc \
--range 10.128.0.0/23 \
--region $REGION --enable-flow-logs \
--enable-private-ip-google-access \
--secondary-range services=10.100.0.0/23,pods=10.0.0.0/16
```

```
gcloud compute networks subnets create gke-staging-cluster-subnet \
--network custom-vpc \
--range 10.129.0.0/23 \
--region $REGION --enable-flow-logs \
--enable-private-ip-google-access \
--secondary-range services=10.100.2.0/23,pods=10.2.0.0/16
```

```
gcloud compute networks subnets create gke-prod-cluster-subnet \
--network custom-vpc \
--range 10.130.0.0/23 \
--region $REGION --enable-flow-logs \
--enable-private-ip-google-access \
--secondary-range services=10.100.4.0/23,pods=10.4.0.0/16
```


**Step 2** Create a `dev`, `staging`, `prod` [GKE autopilot mode clusters](https://cloud.google.com/kubernetes-engine/docs/concepts)

```
gcloud container clusters create-auto dev-cluster \
    --project=${PROJECT_ID} --region=${REGION} \
    --network custom-vpc \
    --subnetwork gke-dev-cluster-subnet \
    --cluster-secondary-range-name pods \
    --services-secondary-range-name services \
    --async

```

```
gcloud container clusters create-auto staging-cluster  \
    --project=${PROJECT_ID} --region=${REGION} \
    --network custom-vpc \
    --subnetwork gke-staging-cluster-subnet \
    --cluster-secondary-range-name pods \
    --services-secondary-range-name services \
    --async
```

```
gcloud container clusters create-auto prod-cluster \
    --project=${PROJECT_ID} --region=${REGION} \
    --network custom-vpc \
    --subnetwork gke-prod-cluster-subnet \
    --cluster-secondary-range-name pods \
    --services-secondary-range-name services \
    --async
```

## Cleanup


```
gcloud container clusters delete dev-cluster --region=${REGION}
gcloud container clusters delete staging-cluster --region=${REGION}
gcloud container clusters delete prod-cluster --region=${REGION}
```

## Using ExternalDNS with GKE Autopilot

The following script configures the clusters, and gcp projects to use GKE workload identity to provide ExternalDNS with the permissions it needs to manage DNS records. Workload identity is the Google-recommended way to provide GKE workloads access to GCP APIs.

```shell
#!/bin/bash

set -x 

sa_display="Workload Identity Service Account for ExternalDNS"
domain="automateit.ca"
dns_project="swampup-2022"

clusters=(staging-cluster dev-cluster prod-cluster)
declare -A service_accounts=(
  [staging-cluster]=sa-stg-edns
  [dev-cluster]=sa-dev-edns
  [prod-cluster]=sa-prod-edns
)

declare -A gcp_projects=(
  [staging-cluster]=swampup-2022
  [dev-cluster]=swampup-2022
  [prod-cluster]=swampup-2022
)
declare -A cluster_regions=(
  [staging-cluster]=us-central1
  [dev-cluster]=us-central1
  [prod-cluster]=us-central1
)


# Loop through Service Accounts for Dev,Stg,Prod Clusters
for cluster in "${clusters[@]}"; do

# Create a GCP service account (GSA) for ExternalDNS and save its email address.
gcloud iam service-accounts create ${service_accounts[$cluster]} --display-name="${sa_display}"

# Bind the ExternalDNS GSA to the DNS admin role.
gcloud projects add-iam-policy-binding ${gcp_projects[$cluster]}\
    --member="serviceAccount:${service_accounts[$cluster]}@${gcp_projects[$cluster]}.iam.gserviceaccount.com" --role=roles/dns.admin


# Link the ExternalDNS GSA to the Kubernetes service account (KSA) that
# external-dns will run under, i.e., the external-dns KSA in the external-dns
# namespaces.
gcloud iam service-accounts add-iam-policy-binding ${service_accounts[$cluster]}@${gcp_projects[$cluster]}.iam.gserviceaccount.com\
    --member="serviceAccount:${gcp_projects[$cluster]}.svc.id.goog[external-dns/${service_accounts[$cluster]}]" \
    --role=roles/iam.workloadIdentityUser \
    --project=$dns_project

gcloud container clusters get-credentials  ${cluster} --project ${gcp_projects[$cluster]} --region ${cluster_regions[$cluster]}

cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Namespace
metadata:
  name: external-dns
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${service_accounts[$cluster]}
  namespace: external-dns
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
rules:
  - apiGroups: [""]
    resources: ["services", "endpoints", "pods"]
    verbs: ["get", "watch", "list"]
  - apiGroups: ["extensions", "networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get", "watch", "list"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
  - kind: ServiceAccount
    name: ${service_accounts[$cluster]}
    namespace: external-dns
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
  namespace: external-dns
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
    spec:
      containers:
        - args:
            - --source=ingress
            - --source=service
            - --domain-filter=${domain}
            - --provider=google
            - --google-project=${dns_project}
            - --registry=txt
            - --txt-owner-id=${cluster}
          image: k8s.gcr.io/external-dns/external-dns:v0.8.0
          name: external-dns
      securityContext:
        fsGroup: 65534
        runAsUser: 65534
      serviceAccountName: ${service_accounts[$cluster]}
EOF

kubectl annotate serviceaccount --namespace=external-dns ${service_accounts[$cluster]} \
    "iam.gke.io/gcp-service-account=${service_accounts[$cluster]}@${gcp_project}.iam.gserviceaccount.com"
done
```