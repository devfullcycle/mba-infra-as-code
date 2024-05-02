provider "aws" {
  region = "us-west-2"
  profile = "lavoro"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
}

resource "aws_instance" "example_instance" {
  ami           = "ami-0663b059c6536cac8"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example_subnet.id
}

resource "aws_eip" "example_eip" {
  instance = aws_instance.example_instance.id
}

output "private_dns" {
  value = aws_instance.example_instance.private_dns
}

output "eip_public_ip" {
  value = aws_eip.example_eip.public_ip
}