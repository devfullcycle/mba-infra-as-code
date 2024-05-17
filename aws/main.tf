terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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
  region     = "us-west-2"
  profile    = "default"
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
  ami           = "ami-01cd4de4363ab6ee8"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example_subnet.id

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
  depends_on = [ aws_internet_gateway.example_igw ]
}

resource "aws_ssm_parameter" "parameter" {
  name  = "vm_ip"
  type  = "String"
  value = aws_eip.example_ip.public_ip
}

output "private_dns" {
  value = aws_instance.example_instance.private_dns  
}

output "eip" {
  value = aws_eip.example_ip.public_ip
}