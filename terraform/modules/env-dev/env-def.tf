# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.

# The dependency of the modules are the same as the order they are listed in this file.

module "project" {
  source                    = "../project"
  prefix                    = var.prefix
  env                       = var.env
  region                    = var.region
  zone                      = var.zone
  project_id                = var.infra_project_id
  project_name              = var.infra_project_name
  folder_id                 = var.folder_id
  billing_account           = var.billing_account
}

module "vpc" {
  source                    = "../vpc"
  prefix                    = var.prefix
  env                       = var.env
  region                    = var.region
  zone                      = var.zone
  # This dependency is here to create project module first.
  infra_project_id          = module.project.project_id
  app_subnet_cidr_block     = var.app_subnet_cidr_block
}

module "vm" {
  source                    = "../vm"
  prefix                    = var.prefix
  env                       = var.env
  region                    = var.region
  zone                      = var.zone
  # This dependency is here to create project module first.
  infra_project_id          = module.project.project_id
  my_workstation_is_linux   = var.my_workstation_is_linux
  app_subnetwork_link       = module.vpc.app_subnetwork_link
}
