module "network" {
  source             = "../modules/network"
  vpc_cidr_block     = var.vpc_cidr_block
  subnet_cidr_blocks = var.subnet_cidr_blocks
  prefix             = var.prefix
}

module "cluster" {
  source             = "../modules/cluster"
  prefix             = var.prefix
  subnet_ids         = module.network.subnet_ids
  security_group_ids = [module.network.security_group_id]
  vpc_id             = module.network.vpc_id
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y nginx
systemctl start nginx
systemctl enable nginx
public_ip=$(curl http://checkip.amazonaws.com)
echo "<html>
  <head><title>Hello</title></head>
  <body>
    <h1>Hello, $public_ip</h1>
  </body>
</html>" | tee /usr/share/nginx/html/index.html > /dev/null
systemctl restart nginx
EOF
  desired_capacity = 1
  min_size = 1
  max_size = 2
  scale_in = var.scale_in
  scale_out = var.scale_out
}
