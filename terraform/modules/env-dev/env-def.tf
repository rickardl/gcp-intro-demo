# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values to env-def which defines the actual environment and creates that environment using given values.

module "project" {
  source                    = "../project"
  prefix                    = var.prefix
  env                       = var.env
  region                    = var.region
  project_name              = var.project_name
  project_id                = var.project_id
}
