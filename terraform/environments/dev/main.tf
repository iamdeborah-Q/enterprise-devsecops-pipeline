
# ==============================================================
# Jerney - AWS EKS Auto Mode Infrastructure
# Region: us-east-2
# Environment: dev
# ==============================================================

# --------------------------------------------------------------
# Availability Zones
# --------------------------------------------------------------

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name = "${var.project}-${var.environment}"

  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    3
  )

  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# --------------------------------------------------------------
# VPC - Public and Private Subnets
# --------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr

  azs = local.azs

  private_subnets = [
    for k, az in local.azs :
    cidrsubnet(var.vpc_cidr, 4, k)
  ]

  public_subnets = [
    for k, az in local.azs :
    cidrsubnet(var.vpc_cidr, 8, k + 48)
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  create_igw = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.tags
}

# --------------------------------------------------------------
# Amazon EKS - Auto Mode
# --------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  # EKS Auto Mode
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose", "system"]
  }

  # VPC Networking
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Kubernetes API Endpoint
  endpoint_private_access = true
  endpoint_public_access  = true

  # Restrict public API access to trusted CIDRs
  endpoint_public_access_cidrs = var.cluster_public_access_cidrs


  # EKS Authentication
  authentication_mode = "API"

  # Grant cluster creator administrator access
  enable_cluster_creator_admin_permissions = true

  # EKS Control Plane Logs
  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # EKS Control Plane Log Retention
  cloudwatch_log_group_retention_in_days = 7

  tags = local.tags
}
