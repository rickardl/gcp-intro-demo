# GCP Short Intro Demonstration For Tieto Specialists  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [WORK IN PROGRESS!!!](#WORK-IN-PROGRESS)
- [Introduction](#Introduction)
- [GCP Terraform Parent Project](#GCP-Terraform-Parent-Project)
- [Deploy the Terraform Infra Code](#Deploy-the-Terraform-Infra-Code)
- [GCP Solution](#GCP-Solution)


# WORK IN PROGRESS!!!

I remove this chapter when this demonstration is ready.

# Introduction

This demonstration can be used in training new cloud specialists who don't need to have any prior knowledge of GCP (Google Cloud Platform) but who want to start working on GCP projects and building their GCP competence.

This demonstration is basically the same as [gcp-intro-dp-demo](https://github.com/tieto-pc/gcp-intro-dp-demo) with one difference: gcp-intro-demo uses [Terraform](https://www.terraform.io/) as IaC tool, and gcp-intro-dp-demo uses [GCP Deployment Manager](https://cloud.google.com/deployment-manager/docs/). The idea is to introduce another way to create infrastructure code in GCP and let developers to compare Terraform and GCP Deployment Manager and makel their own decision which tool to use in their future projects.

This project demonstrates basic aspects how to create cloud infrastructure using code. The actual infra is very simple: just one virtual machine instance. We create a virtual private cloud [vpc](https://cloud.google.com/vpc/) and an application subnet into which we create the [VM](https://cloud.google.com/compute/docs/instances/). There is also one [firewall](https://cloud.google.com/vpc/docs/firewalls) in the VPC that allows inbound traffic only using ssh port 22. 

I tried to keep this demonstration as simple as possible. The main purpose is not to provide an example how to create a cloud system (e.g. not recommending VMs over containers) but to provide a very simple example of infrastructure code and tooling related creating the infra. I have provided some suggestions how to continue this demonstration at the end of this document - you can also send me email to my corporate email and suggest what kind of GCP or GCP POCs you need in your team - I can help you to create the POCs for your customer meetings.

NOTE: There are equivalent AWS demonstration - [aws-intro-demo](https://github.com/tieto-pc/aws-intro-demo), and Azure demonstration - [azure-intro-demo](https://github.com/tieto-pc/azure-intro-demo) - compare the terraform code between these GCP, AWS and Azure infra implementations and you realize how similar they are.

# GCP Terraform Parent Project

First let's create a Terraform parent project which hosts the Terraform state files and also the GCP Service account so that these entities do not belong to the actual GCP demo project. So, the idea is to divide Terraform state & deployment infra (state file & service account to run infra deployments) separate from the actual GCP infra entities that are part of the demo infra. Follow instructions given in document [Getting started with Terraform on Google Cloud Platform](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform). Create a project and create the entities as described in that document.

We will create this parent project and entities manually since they are not part of the actual demo infra. We use document [Managing GCP projects with Terraform](https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform) - note: I don't follow the document in every detail (e.g. not creating billing accounts etc.).

1. Create a parent project as documented in [Creating and Managing Projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects).
2. Create service account as documented in [Creating and managing service accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts).

NOTE: See [GCP gcloud configuration](https://cloud.google.com/sdk/gcloud/reference/config/configurations/) documentation for more information how to create gcloud configurations (e.g. for command gcloud init).

You can also create the service account using the following commands. You may want to create a separate gcloud configuration for this parent project.

```bash
 # First check current GCP project.
gcloud config get-value project
# You may want to create a new gcloud configuration for this project and set the terraform parent project as the default project and set the default region and zone...
gcloud init
# Create service account.
export TF_CREDS=~/.config/gcloud/<YOUR-NAME>-terraform-parent.json
export TF_ADMIN=<YOUR-NAME>-terraform-parent
gcloud iam service-accounts create terraform --display-name "terraform-service-account"
gcloud iam service-accounts keys create ${TF_CREDS} --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com
# Add roles.
gcloud projects add-iam-policy-binding ${TF_ADMIN} --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com --role roles/viewer
gcloud projects add-iam-policy-binding ${TF_ADMIN} --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com --role roles/storage.admin
gcloud organizations add-iam-policy-binding tieto.com --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com --role roles/resourcemanager.projectCreator
# Make Cloud storage bucket.
gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}
gsutil versioning set on gs://${TF_ADMIN}

```


# Deploy the Terraform Infra Code

Run usual terraform init / get / plan / deploy.





# GCP Solution

The diagram below depicts the main services / components of the solution. TODO...
