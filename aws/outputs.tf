output "private_dns" {
  value = aws_instance.example_instance.private_dns
}

# output "eip" {
#   value = aws_eip.example_ip.public_ip
# }