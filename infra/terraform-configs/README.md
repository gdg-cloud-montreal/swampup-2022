# Creation of GCP Infrastructure with Terraform

This terraform automation, is focused on creating gcp services such as VPC, VPC subnets, GKE Autopilot and Cloud Deploy Pipelines

**Step 1** Create GCS bucket for terraform state:

```
gcloud storage buckets create gs://swampup-tfstate
```


**Step 1** Edit `terraform.tfvars` file with information specific to your environment, such as `gcp_project_id`


```
vim terraform.tfvars
```

**Step 3** Now that you have declared and configured the GCP provider for terraform and project specific information, initialize terraform:

```
terraform init
```

**Step 4** Run `terraform plan` command:

```
terraform plan -var-file terraform.tfvars
```

!!! result
    `Plan: 7 to add, 0 to change, 0 to destroy.`

```
terraform apply -var-file terraform.tfvars
```

Verify 3 `GKE Autopilot` has been created:

```
gcloud container clusters list
```


