locals {
  prefix = "devops-project-${local.region}-${local.env}"
  region = "us-east-1"
  env    = "dev"
  tags = {
    "Environment" = local.env
    "Project"     = "devops-project"
    "Region"      = local.region
  }
}

module "vpc" {
  source = "./modules/vpc"

  name = "${local.prefix}-vpc"

  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  public_subnets  = ["10.0.128.0/19", "10.0.160.0/19", "10.0.192.0/19"]

  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${local.prefix}-eks" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${local.prefix}-eks" = "owned"
  }

  tags = local.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "${local.prefix}-eks"
  cluster_version = "1.31"

  endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = local.tags
}

module "rds" {
  source = "./modules/rds"

  db_name = "${local.prefix}-rds"

  # vpc_id     = module.vpc.vpc_id
  # subnet_ids = module.vpc.private_subnets

  tags = local.tags
}

module "redis" {
  source = "./modules/redis"

  cluster_name = "${local.prefix}-redis"

  # vpc_id     = module.vpc.vpc_id
  # subnet_ids = module.vpc.private_subnets

  tags = local.tags
}
