module "network" {
  source = "./network"

  project_name       = local.project_name
  cidr_block         = var.cidr_block
  availability_zones = var.availability_zones
}
