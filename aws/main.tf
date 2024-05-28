module "network" {
  source             = "./modules/network"
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
  prefix             = var.prefix
}

module "cluster" {
  source             = "./modules/cluster"
  prefix             = var.prefix
  subnet_id          = module.network.subnet_ids[0]
  instance_count     = var.instance_count
  security_group_ids = [module.network.security_group_id]
}
