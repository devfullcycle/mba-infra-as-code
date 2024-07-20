provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

variables {
  prefix             = "test"
  vpc_cidr_block     = "10.0.0.0/18"
  subnet_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
}

run "valid_vpc" {
  command = plan

  assert {
    condition     = aws_vpc.vpc.cidr_block == "10.0.0.0/18"
    error_message = "Unexpected CIDR block"
  }

  assert {
    condition     = aws_vpc.vpc.tags.Name == "test-vpc"
    error_message = "Unexpected name tag"
  }
}

run "valid_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.subnets) == length(var.subnet_cidr_blocks)
    error_message = "Incorrect number of subnets."
  }

  assert {
    condition     = aws_subnet.subnets[0].cidr_block == var.subnet_cidr_blocks[0]
    error_message = "Incorret CIDR block for Subnet 0"
  }

  assert {
    condition     = aws_subnet.subnets[1].cidr_block == var.subnet_cidr_blocks[1]
    error_message = "Incorret CIDR block for Subnet 1"
  }

  assert {
    condition     = aws_subnet.subnets[0].availability_zone != aws_subnet.subnets[1].availability_zone
    error_message = "The subnets shouldn't be in the same AZ"
  }
}