module "network" {
  source = "./modules/network"

  project_name       = var.project_name
  cidr_block         = var.cidr_block
  availability_zones = var.availability_zones
}
