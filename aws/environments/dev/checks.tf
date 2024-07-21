data "aws_lb" "lb" {
  arn = module.cluster.lb_arn
}

check "http" {
  data "http" "lb" {
    url                = "http://${data.aws_lb.lb.dns_name}"
    request_timeout_ms = 5000
    retry {
      attempts     = 5
      min_delay_ms = 1000
      max_delay_ms = 10000
    }
  }

  assert {
    condition     = data.http.lb.status_code == 200
    error_message = "The web app is not available."
  }
}
