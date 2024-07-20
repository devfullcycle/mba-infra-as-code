provider "aws" {
  region  = "us-west-2"
  profile = "default"
}

variables {
  prefix = "test"
}

run "network" {
  command = apply
  variables {
    vpc_cidr_block     = "10.0.0.0/18"
    subnet_cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
  }

  module {
    source = "../network"
  }

  assert {
    condition     = length(output.subnet_ids) == 2
    error_message = "There should have been create 2 subnets."
  }
}

run "cluster" {
  command = apply
  variables {
    subnet_ids         = run.network.subnet_ids
    security_group_ids = [run.network.security_group_id]
    vpc_id             = run.network.vpc_id
    user_data          = <<EOF
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
EOF
    desired_capacity   = 1
    min_size           = 1
    max_size           = 1
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
  }

  assert {
    condition     = aws_lb.app_lb.dns_name != null
    error_message = "Invalid DNS name"
  }
}

run "verify_http" {
  command = apply
  variables {
    lb_arn = run.cluster.lb_arn
  }

  module {
    source = "./testing/http"
  }

  assert {
    condition     = data.http.lb.status_code == 200
    error_message = "The web app is not available."
  }
}