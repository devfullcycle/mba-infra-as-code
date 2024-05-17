terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
  }
}

data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-west-2:304851244121:secret:prod/Terraform/Db-3vtdtk"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_instance" "example_instance" {
  ami                    = "ami-01cd4de4363ab6ee8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.example_subnet.id
  vpc_security_group_ids = [aws_security_group.example_sg.id]

  user_data = <<EOF
#!/bin/bash
DB_STRING="Server=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["Host"]};DB=${jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["DB"]}"
echo $DB_STRING > test.txt
EOF
}

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
}

resource "aws_eip" "example_ip" {
  instance   = aws_instance.example_instance.id
  depends_on = [aws_internet_gateway.example_igw]
}

resource "aws_ssm_parameter" "parameter" {
  name  = "vm_ip"
  type  = "String"
  value = aws_eip.example_ip.public_ip
}

resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
}

resource "aws_route_table_association" "example_route_table_association" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

resource "aws_security_group" "example_sg" {
  vpc_id = aws_vpc.example_vpc.id
  name   = "Allow SSH"

  tags = {
    Name = "Allow SSH"
  }
}

resource "aws_vpc_security_group_ingress_rule" "example_sg_ingress_rule" {
  security_group_id = aws_security_group.example_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "example_sg_egress_rule" {
  security_group_id = aws_security_group.example_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


output "private_dns" {
  value = aws_instance.example_instance.private_dns
}

output "eip" {
  value = aws_eip.example_ip.public_ip
}
