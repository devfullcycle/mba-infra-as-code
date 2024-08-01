terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.3"
    }
  }
}

data "aws_lb" "lb" {
  arn = var.lb_arn
}

data "http" "lb" {
  url                = "http://${data.aws_lb.lb.dns_name}"
  request_timeout_ms = 5000
  retry {
    attempts     = 5
    min_delay_ms = 1000
    max_delay_ms = 10000
  }
}


