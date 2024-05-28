output "private_dns" {
  value = module.cluster.private_dns
}

# output "eip" {
#   value = aws_eip.example_ip.public_ip
# }