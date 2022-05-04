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


**Step 4** Create `dev`, `stg`, `prod` subnets for custom-vpc


```
env  |   subnet      | pod range       | srv range       | kubectl api range
dev  | 10.128.0.0/23 | 10.0.0.0/16     | 10.100.0.0/23   | 172.16.0.0/28
stg  | 10.129.0.0/23 | 10.2.0.0/16     | 10.100.2.0/23   | 172.16.0.16/28
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
gcloud compute networks subnets create gke-stg-cluster-subnet \
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


**Step 2** Create a `dev`, `stg`, `prod` [GKE autopilot mode clusters](https://cloud.google.com/kubernetes-engine/docs/concepts)

```
gcloud container clusters create-auto dev-cluster \
    --project=${PROJECT_ID} --region=${REGION} \
    --network custom-vpc \
    --subnetwork gke-dev-cluster-subnet \
    --cluster-secondary-range-name pods \
    --services-secondary-range-name services
```

```
gcloud container clusters create-auto stg-cluster  \
    --project=${PROJECT_ID} --region=${REGION} \
    --network custom-vpc \
    --subnetwork gke-stg-cluster-subnet \
    --cluster-secondary-range-name pods \
    --services-secondary-range-name services
```

```
gcloud container clusters create-auto prod-cluster \
    --project=${PROJECT_ID} --region=${REGION} \
    --network custom-vpc \
    --subnetwork gke-prod-cluster-subnet \
    --cluster-secondary-range-name pods \
    --services-secondary-range-name services
```

## Cleanup


```
gcloud container clusters delete dev-cluster --region=${REGION}
gcloud container clusters delete stg-cluster --region=${REGION}
gcloud container clusters delete prod-cluster --region=${REGION}
```
