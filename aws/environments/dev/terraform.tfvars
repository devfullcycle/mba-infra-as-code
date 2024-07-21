prefix             = "dev-fullcycle"
vpc_cidr_block     = "172.16.0.0/16"
subnet_cidr_blocks = ["172.16.0.0/24", "172.16.1.0/24"]
scale_in = {
  cooldown           = 60
  threshold          = 20
  scaling_adjustment = -1
}
scale_out = {
  cooldown           = 60
  threshold          = 70
  scaling_adjustment = 1
}