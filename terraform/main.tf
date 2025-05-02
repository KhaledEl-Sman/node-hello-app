resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "hello-node-vpc"
  }
}

resource "aws_subnet" "subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "hello-node-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "hello-node-igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "hello-node-route-table"
  }
}

resource "aws_route_table_association" "associations" {
  count          = 3
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hello-node-web-sg"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
    
  cluster_name                    = var.cluster_name
  cluster_version                 = "1.31"
  cluster_endpoint_public_access = true
    
  vpc_id                     = aws_vpc.main.id
  subnet_ids                = aws_subnet.subnets[*].id
  control_plane_subnet_ids  = aws_subnet.subnets[*].id
    
  eks_managed_node_groups = {
    green = {
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    min_size       = 2
    max_size       = 3
    desired_size   = 2
    instance_types = var.node_instance_types
    update_config = {
        max_unavailable = 1
    }

    bootstrap_extra_args = "--use-max-pods false"
    pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        echo "--max-pods=50" >> /etc/eks/bootstrap.sh
    EOT
    }
  }

  tags = {
    Environment = "hello-node"
    Terraform   = "true"
  }
}

resource "kubernetes_secret_v1" "newrelic_license" {
  metadata {
    name = "newrelic-license-key"
    namespace = "newrelic"
  }

  data = {
    licenseKey = var.newrelic_license_key
  }

  depends_on = [module.eks]
}

resource "helm_release" "newrelic" {
  name       = "newrelic"
  repository = "https://helm-charts.newrelic.com"
  chart      = "nri-bundle"
  namespace  = "newrelic"
  create_namespace = true

  set {
    name  = "global.cluster"
    value = var.cluster_name
  }

  set {
    name  = "global.licenseKeySecret.name"
    value = kubernetes_secret_v1.newrelic_license.metadata[0].name
  }

  set {
    name  = "global.licenseKeySecret.key"
    value = "licenseKey"
  }

  depends_on = [kubernetes_secret_v1.newrelic_license]
}
