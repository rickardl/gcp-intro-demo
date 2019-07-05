# GCP Short Intro Demonstration For Tieto Specialists  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#Introduction)
- [GCP Solution](#GCP-Solution)
- [GCP Terraform Parent Project](#GCP-Terraform-Parent-Project)
- [Deploy the Terraform Infra Code](#Deploy-the-Terraform-Infra-Code)
- [Terraform Code](#Terraform-Code)
- [Terraform File Types](#Terraform-File-Types)
- [Terraform Env and Modules](#Terraform-Env-and-Modules)
  - [Env Parameters](#Env-Parameters)
  - [Env-def Module](#Env-def-Module)
  - [Project Module](#Project-Module)
  - [Vpc Module](#Vpc-Module)
  - [VM Module](#VM-Module)
- [Terraform Backend](#Terraform-Backend)
- [Demonstration Manuscript](#Demonstration-Manuscript)
- [Suggestions How to Continue this Demonstration](#Suggestions-How-to-Continue-this-Demonstration)
- [Investigating Connectivity Issue](#Investigating-Connectivity-Issue)
- [Some Considerations](#Some-Considerations)



# Introduction

This demonstration can be used in training new cloud specialists who don't need to have any prior knowledge of GCP (Google Cloud Platform) but who want to start working on GCP projects and building their GCP competence (well, a bit of GCP knowledge is required - GCP main concepts, how to use the GCP Portal and CLI).

This demonstration is basically the same as [gcp-intro-dp-demo](https://github.com/tieto-pc/gcp-intro-dp-demo) (TODO: WILL BE IMPLEMENTED LATER) with one difference: gcp-intro-demo uses [Terraform](https://www.terraform.io/) as IaC tool, and gcp-intro-dp-demo uses [GCP Deployment Manager](https://cloud.google.com/deployment-manager/docs/). The idea is to introduce another way to create infrastructure code in GCP and let developers to compare Terraform and GCP Deployment Manager and make their own decision which tool to use in their future projects.

This project demonstrates basic aspects how to create cloud infrastructure as code. The actual infra is very simple: just one virtual machine instance. We create a virtual private cloud [vpc](https://cloud.google.com/vpc/) and an application subnet into which we create a [VM](https://cloud.google.com/compute/docs/instances/). There is also one [firewall](https://cloud.google.com/vpc/docs/firewalls) in the VPC that allows inbound traffic only using ssh port 22. The IaC also creates a ssh key pair - the public key gets stored in your workstation, the private key will be installed to the VM.

I tried to keep this demonstration as simple as possible. The main purpose is not to provide an example how to create a cloud system (e.g. not recommending VMs over containers) but to provide a very simple example of infrastructure code and tooling related creating the infra. I have provided some suggestions how to continue this demonstration at the end of this document - you can also send me email to my corporate email and suggest what kind of GCP or GCP POCs you need in your team - I can help you to create the POCs for your customer meetings.

NOTE: There are two equivalent demonstrations in other "Big three" cloud provider platforms: AWS demonstration - [aws-intro-demo](https://github.com/tieto-pc/aws-intro-demo), and Azure demonstration - [azure-intro-demo](https://github.com/tieto-pc/azure-intro-demo) - compare the terraform code between these GCP, AWS and Azure infra implementations and you realize how similar they are.

NOTE. There are a lot of [Terraform examples provided by Google](https://github.com/GoogleCloudPlatform/terraform-google-examples) - you should use these examples as a starting point for your own GCP Terraform IaC, I did too.


# GCP Solution

The diagram below depicts the main services / components of the solution.

![GCP Intro Demo Architecture](docs/gcp-intro-demo.png?raw=true "GCP Intro Demo Architecture")

So, the system is extremely simple (for demonstration purposes): Just one VPC, one application subnet and one Compute instance (VM) doing nothing in the subnet. One Firewall rule in the VPC which allows only ssh traffic to the Compute instance. 



# GCP Terraform Parent Project

First let's create a Terraform parent project which hosts the Terraform state file in a Cloud storage so that it is not part of the actual GCP demo infra project. So, the idea is to divide Terraform state infra (state file) separate from the actual GCP infra entities that are part of the demo infra. Follow instructions given in document [Getting started with Terraform on Google Cloud Platform](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform). We will create this parent project using a script provided by this demonstration.

NOTE: We cannot use document [Managing GCP projects with Terraform](https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform) since it would require that we can give the service account the project creator role for the organization - not possible in my corporation GCP organization. 

NOTE: This is just one possible solution. This solution allows the infra project to be part of the IaC - another solution would be to create the infra project separately (just the GCP project) and then use IaC to deploy the infra entities (VPC, VM...) into that project - this solution would have been a bit simpler considering the environment variables. In that solution you also could use service account since you wouldn't need to create the project in IaC.

First create environment variables file in ~/.gcp/<YOUR-ADMIN-FILE>.sh. Use file [gcp_env_template.sh](gcp_env_template.sh) as a template.

Then create admin entities.

```bash
# Source environment variables.
source ~/.gcp/<YOUR-ADMIN-FILE>.sh

# Create admin entities.
./create-admin-proj.sh
```

NOTE: There is a chicken and egg problem here regarding the issue I explained above (whether the GCP project is part of IaC or not). In [dev.tf](terraform/envs/dev/def.tf) we are using the admin project in the google provider (since this definition will create infra project as part of the IaC). Therefore we need to inject the infra_project_id to every entity created as part of the infra IaC. I need to investigate this a bit later. I have added a unique identifier to be added to the infra project id (see [gcp_env_template.sh](gcp_env_template.sh) - ```GCP_ADMIN_VERSION``` and ```GCP_INFRA_VERSION```). GCP does not allow you to use the same project id even if you deleted the project with that project id earlier - so, if you delete the project and create the project again - you need to give a new unique project id. Therefore increment the project id numbers in your environment file, and source the file before running the [create-admin-proj.sh](create-admin-proj.sh) script for creating the admin project or running terraform init/get/plan/apply for the infra project.


# Deploy the Terraform Infra Code

Go to terraform/env/dev directory. Source the environment variables file if this is a new terminal.

You have to manually set the backend bucket since variables are not allowed in the terraform section. Check the bucket name first: ```echo $TF_VAR_TERRA_BACKEND_BUCKET_NAME```. Then populate the value in [dev.tf](terraform/envs/dev/dev.tf):

```text
bucket           =  "<GIVE-BUCKET-NAME-HERE>"
```

Then you are ready to run the usual terraform init/get/plan/deploy commands.


# Terraform Code

I am using [Terraform](https://www.terraform.io/) as an [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code) (IaC) tool. I'm using the new Terraform v. 0.12 version which has some major changes compared to previous versions - e.g. regarding interpolation (therefore there are some differences regarding this gcp-intro demo and previous aws-intro-demo and azure-intro-demo). Terraform is very much used in AWS, Azure and GCP cloud platforms to create IaC solutions and one of its strenghts compared to cloud native tools (AWS / [CloudFormation](https://aws.amazon.com/cloudformation), Azure / [ARM template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates) and GCP / [Deployment Manager](https://cloud.google.com/deployment-manager/) ) is that you can use Terraform with many cloud providers, you have to learn just one infra language and syntax, and Terraform language (hcl) is pretty powerful and clear. When deciding the actual infra code tool you should consult the customer if there is some tooling already decided. Otherwise you should evaluate Deployment Manager and Terraform and then decide which one is more appropriate for the needs of your GCP cloud project.

If you are new to infrastructure as code (IaC) and terraform specifically let's explain the high level structure of the terraform code first. Project's terraform code is hosted in [terraform](terraform) folder.

It is a cloud best practice that you should modularize your infra code and also modularize it so that you can create many different (exact or as exact as you like) copies of your infra  re-using the infra modules. I use a common practice to organize terraform code in three levels:

1. **Environment parameters**. In [envs](terraform/envs) folder we host the various environments. In this demo we have only the dev environment, but this folder could have similar env parameterizations for qa, perf, prod environments etc. 
2. **Environment definition**. In [env-def](terraform/modules/env-def) folder we define the modules that will be used in every environment. The environments inject the environment specific parameters to the env-def module which then creates the actual infra using those parameters by calling various infra modules and forwarding environment parameters to the infra modules.
3. **Modules**. In [modules](terraform/modules) folder we have the modules that are used by environment definition (env-def, a terraform module itself also). There are modules for the main services used in this demonstration: [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects), [vpc](https://cloud.google.com/vpc/) and [vm](https://cloud.google.com/compute/docs/instances/).


# Terraform File Types

There are basically three types of Terraform files in this demonstration:
- The actual infra definition file with the same name as the module folder.
- Variables file. You use variables file to declare variables that are used in that specific module.
- Outputs file. You can use outputs file as a mechanism to print certain interesting infra values. Outputs are also a mechanism to transfer infra information from one module to another.

I encourage the reader to read more about Terraform in [Terraform documentation](https://www.terraform.io/docs/index.html).


# Terraform Env and Modules

In this chapter we walk through the terraform modules a bit deeper.

## Env Parameters

You can find all parameters related to dev env in file [dev.tf](terraform/envs/dev/dev.tf). Open the file.

This file starts with the terraform backend - more about it later in the "Terraform Backend" chapter. What you now need to know is that you need to create a GCP Cloud storage bucket - this will be created using the script provided in this demonstration.

After the backend configuration we have the terraform locals definition - these are provided for this context and we use them to inject the parameter values to the env-def module which follows right after the locals definition.

After locals there is the provider definition (google apparently in the case of this GCP demonstration). 

Finally we inject the dev env parameters to the env-def module.



## Env-def Module

All right! In the previous file we injected dev env parameters to the [env-def.tf](terraform/modules/env-def/env-def.tf) module. Open this file now.

You see that this module defines three other modules. The idea is that this env-def - Environment definition - can be re-used by all envs, like ```dev```, ```qa```, ```perf``` and ```prod``` etc - they all just inject their env specific parameters to the same environment definition which gives a more detailed definition what kind of modules there are in this infrastructure.

So, this environment defition defines three modules: project, vpc and vm. Let's walk through those modules next.


## Project Module

The [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) definition creates the infra project that will host all resources in this demonstration. IaC also links this new project to the folder we are using (if you don't have a folder modify the code) and to a billing account (you must have a billing account in order to create resources). We also set auto-create-network to false since we don't want that GCP creates a default VPC for us which it would normally do.

We also turn on certain GCP APIs we need in this project (compute related).



## Vpc Module

The [vpc](https://cloud.google.com/vpc/) definition creates the VPC (virtual private cloud), subnet and the firewall rule to allow ssh traffic to this VPC. We set auto-create-subnetworks to false since we want to create the subnet using IaC in this demonstration.

Note that in GCP VPC is a global entity and you don't assign an address space ([cidr](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)) to it as in AWS and Azure. You assign the address space to subnet. You also need to provide the infra project id which is used to host subnet and firewall rule (and later compute instance).

Finally there is a [firewall rule](https://cloud.google.com/vpc/docs/firewalls) defintion which opens port 22 for ssh connections. NOTE: We do not restrict any source addresses - in real world system you should restrict the source ip addresses, of course. But don't worry - there is just one VM and we protect the VM with ssh keys (see VM chapter later).


## VM Module


The [vm](https://cloud.google.com/compute/docs/instances/) module is a also a bit more complex. But let's not be intimidated - let's see what kind of bits and pieces there are in this module. 

We first create the ssh keys to be used for both *nix and Windows workstations (client side). 

Then we create the external static ip for the compute instance. 

Finally there is the compute instance defitinion. We link this instance to the infra project, provide values for various parameters (zone...) and inject the public ssh key to the machine (to be used later when we use ssh to connect to the VM). We also provide a set of labels for the VM.



# Terraform Backend

In a small project like this in which you are working alone you don't actually need a Terraform backend but I have used it in this demonstration to make a more realistic demonstration. You should use Terraform backend in any project that has more than one developer. The reason for using a Terraform backend is to store and lock your terraform state file so that many developers cannot concurrently make conflicting changes to the infrastructure.

The demonstration provides the environment variables source file template and scripts to setup admin project and GCP gcloud configuration for the infra project. Use the scripts as explained in the Demonstration Manuscript chapter. The script also creates the GCP Cloud storage bucket in the admin project which is used to host the Terraform backend state file.


NOTE: If you need to delete the backend completely, then delete these:
- the ```.terraform``` folder in your terraform/envs/dev folder
- the terraform state file in your Cloud storage bucket (do not delete the bucket - just the file)



# Demonstration Manuscript

NOTE: These instructions are for Linux (most probably should work for Mac as well). If some Tieto employee is using Windows I would appreciate to get a merge request to provide instructions for a Windows workstation as well.

Let's finally give detailed demonstration manuscript how you are able to deploy the infra of this demonstration to your GCP account. You need a GCP account for this demonstration. You can order a private GCP account or you can contact your line manager if you are allowed to use Tieto's GCP account (contact the administrator in Tieto Yammer Google Cloud Platform group).  **NOTE**: Watch for costs! Always finally destroy your infrastructure once you are ready (never leave any resources to run indefinitely in your GCP account to generate costs).

1. Install [Terraform](https://www.terraform.io/). You might also like to add Terraform support for your favorite editor (e.g. there is a Terraform extension for VS Code).
2. Install [GCP command line interface](https://cloud.google.com/sdk/).
3. Clone this project: git clone https://github.com/tieto-pc/gcp-intro-demo.git
4. Create the environment variables file as described earlier. Use [gcp_env_template.sh](gcp_env_template.sh) as a template.
5. Open console and source the environment variable file (```source <FILE>```). Create the admin project and the terraform backend cloud storage bucket using the [create-admin-proj.sh](create-admin-proj.sh) script as described earlier.
6. Create project infra gcloud configuration:
   1. Source your environment variables file: ```source <FILE>```
   2. Use script [create-infra-configuration.sh](create-infra-configuration.sh).
7. Open console in [dev](terraform/envs/dev) folder. Give commands
   1. Source your environment variables file: ```source <FILE>```
   2. Check that you are using the right gcloud configuration: ```gcloud config configurations list```
   3. ```terraform init``` => Initializes the Terraform backend state.
   4. ```terraform get``` => Gets the terraform modules of this project.
   5. ```terraform plan``` => Gives the plan regarding the changes needed to make to your infra. **NOTE**: always read the plan carefully!
   6. ```terraform apply``` => Creates the delta between the current state in the infrastructure and your new state definition in the Terraform configuration files.
8. Open GCP Portal and browse different views to see what entities were created:
   1. Home => Select the project you created.
   2. Click the "VPC Network". Browse subnets etc.
   3. Click the "Compute Engine". Browse different information regarding the VM.
9.  Test to get ssh connection to the VM instance:
    1.  ```gcloud compute instances list``` => list VMs (should be only one) => check the external ip.
    2.  ssh -i terraform/modules/vm/.ssh/vm_id_rsa user@IP-NUMBER-HERE
10. Finally destroy the infra using ```terraform destroy``` command. Check manually also using Portal that terraform destroyed all resources. **NOTE**: It is utterly important that you always destroy your infrastructure when you don't need it anymore - otherwise the infra will generate costs to you or to your unit.

The official demo is over. Next you could do the equivalent [gcp-intro-dp-demo](https://github.com/tieto-pc/gcp-intro-dp-demo) that uses GCP Deployment Manager. Then compare the Terraform and Deployment Manager code and also the workflows. Evaluate the two tools - which pros and cons they have when compared to each other? Which one would you like to start using? And why?


# Suggestions How to Continue this Demonstration

We could add e.g. an instance group and a load balancer to this demonstration but let's keep this demonstration as short as possible so that it can be used as a GCP introduction demonstration. If there are some improvement suggestions that our Tieto developers would like to see in this demonstration let's create other small demonstrations for those purposes, e.g.:
- Create a custom Linux image that has the Java app baked in.
- An instance group (with CRM app baked in) + a load balancer.
- Logs to StackDriver.
- Use container instead of VM.


# Investigating Connectivity Issue

When I created the first version of VPC, subnetwork, firewall and VM I couldn't connect to the VM neither using Console SSH or ssh from my local workstation. The VM was not reachable using ping. I created another standard VM using GCP Console into the same subnetwork - same thing. GCP provided nice document for solving connectivity issues: [Troubleshooting SSH](https://cloud.google.com/compute/docs/troubleshooting/troubleshooting-ssh). That document didn't help though. A seasoned cloud developer has a best practice in situation like this. Create another version of the entities using either Portal or some tutorial instructions that should work. Verify that the tutorial version works. Then compare all entities (your not-working entity and equivalent tutorial working entity) - in some entity you should see some discrepancy which should give you either the culprit itself or at least some clues how to investivate the issue further. So, I created another custom VPC, subnetwork and firewall using instructions in [Using VPC](https://cloud.google.com/vpc/docs/using-vpc) and was able to pinpoint the issue and fix it. 

While investigating the issue I noticed that when choosing the instance in GCP Console and clicking Edit button and checking the ssh key it complains: ```Invalid key. Required format: <protocol> <key-blob> <username@example.com> or <protocol> <key-blob> google-ssh {"userName":"<username@example.com>", expireOn":"<date>"}``` ... but logging to instance using the key succeeds: ```ssh -i terraform/modules/vm/.ssh/vm_id_rsa user@<EXTERNAL-IP>```. I didn't bother to investigate reason for that error message since I could ssh to the instance using the key.


# Some Considerations

There is some hassle if you want the GCP infra project be part of your IaC solution. E.g. you have to manually set the infra project id to all resources since the project is not yet ready when you call the Terraform google provider. Also if you want to run the IaC in one shot this is a bit problematic since when Terraform/GCP creates the project and you have added the billing account as a parameter you will get an error: ```Error: Error creating Subnetwork: googleapi: Error 403: Project kari-dev-gcp-intro-demo-id-8 cannot accept requests to insert while in an inactive billing state.  Billing state may take several minutes to update., inactiveBillingState```. I managed to fix that issue later by outputting the infra project id from the project module (even though it is in the environment variable in this demonstration) and injecting that dependency to vpc and vm modules - end result: the project entity (with the billing account link) needs to be created first before Terraform continues to create the resources that need a billing account.

Also the [gcp_env_template.sh](gcp_env_template.sh) / ```GCP_INFRA_VERSION``` is a bit clumsy. In this sense the Azure Resource group behaves better from the IaC point of view. Another solution could be just to create the infra project manually (using either GCP Console or GCP CLI) and add the infra project id as parameter to the Terraform IaC code. Now that I have seen how to create the project using Terraform I'm turning to the idea not having the project as part of the IaC solution.


