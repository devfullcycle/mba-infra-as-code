output "private_dns" {
  value = aws_instance.instances[0].private_dns
}