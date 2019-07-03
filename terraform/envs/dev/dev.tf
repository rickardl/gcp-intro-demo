# Dev environment.
# NOTE: If environment copied, change environment related values (e.g. "dev" -> "perf").


##### Terraform configuration #####

# Usage:
# terraform init
# terraform get
# terraform plan
# terraform apply

# NOTE: If you want to create a separate version of this demo, use a unique prefix, e.g. "myname-intro-demo".
# This way all entities have a different name and also you create a dedicate terraform state file
# (remember to call 'terraform destroy' once you are done with your experimentation).
# So, you have to change the prefix in both local below and terraform configuration section in key.


# NOTE: You cannot use locals in the terraform configuration since terraform
# configuration does not allow interpolation in the configuration section.

terraform {
  required_version = ">=0.12.3"
  backend "gcs" {
    # NOTE ***********************************************************************************************
    # NOTE: Change here the bucket name that you use to store Terraform backend.
    # NOTE: Variables not allowed here, therefore check it: echo $TF_VAR_TERRA_BACKEND_BUCKET_NAME
    # NOTE ***********************************************************************************************
    bucket           =  "marttkar-terraform-5"
    prefix           = "gcp-intro-demo/dev/terraform.tfstate"
  }
}

locals {
  # Use unique environment names, e.g. dev, custqa, qa, test, perf, ci, prod...
  my_env                = "dev"
  # Use consistent prefix, e.g. <cloud-provider>-<demo-target/purpose>-demo, e.g. aws-ecs-demo
  my_prefix             = "gcp-intro-demo"

  # TODO
  vpc_cidr_block        = "10.50.0.0/16"
  app_subnet_cidr_block = "10.50.1.0/24"
}

provider "google" {
  project = var.ADMIN_PROJ_ID
  region  = var.REGION
  zone    = var.ZONE
}



# Here we inject our values to the environment definition module which creates all actual resources.
module "env-def" {
  source             = "../../modules/env-dev"
  prefix             = local.my_prefix
  env                = local.my_env
  region             = var.REGION
  infra_project_id   = var.INFRA_PROJ_ID
  infra_project_name = var.INFRA_PROJ_NAME
  folder_id          = var.FOLDER_ID
  billing_account    = var.BILLING_ACCOUNT_ID

  vpc_cidr_block        = local.vpc_cidr_block
  app_subnet_cidr_block = local.app_subnet_cidr_block
}


