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

NOTE. There are a lot of [Terraform examples provided by Google](https://github.com/GoogleCloudPlatform/terraform-google-examples) - you should use these examples as a starting point for your own GCP Terraform IaC, I did too.


# GCP Terraform Parent Project

First let's create a Terraform parent project which hosts the Terraform state file in a Cloud storage so that it is not part of the actual GCP demo infra project. So, the idea is to divide Terraform state & deployment infra (state file) separate from the actual GCP infra entities that are part of the demo infra. Follow instructions given in document [Getting started with Terraform on Google Cloud Platform](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform). We will create this parent project using a script provided by this demonstration.

NOTE: We cannot use document [Managing GCP projects with Terraform](https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform) since it would require that we can give the service account the project creator role for the organization - not possible in my corporation GCP organization. 

First create environment variables file in ~/.gcp/<YOUR-ADMIN-FILE>.sh. Use file [gcp_env_template.sh](gcp_env_template.sh) as a template.


Then create admin entities.

```bash
# Source environment variables.
source ~/.gcp/<YOUR-ADMIN-FILE>.sh

# Create admin entities.
./create-admin-proj.sh
```


# Deploy the Terraform Infra Code

Go to terraform/env/dev directory. 

You have to manually set the backend bucket since variables are not allowed in the terraform section.
Check the bucket name first: ```echo $TF_VAR_TERRA_BACKEND_BUCKET_NAME```
Then populate the value in [dev.tf](terraform/envs/dev/dev.tf):
```text
bucket           =  "<GIVE-BUCKET-NAME-HERE>"
```
Then you are ready to run the usual terraform init/get/plan/deploy commands.


# GCP Solution

The diagram below depicts the main services / components of the solution. TODO...
