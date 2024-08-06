prefix             = "fullcycle"
vpc_cidr_block     = "10.0.0.0/16"
subnet_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
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