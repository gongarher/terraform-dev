locals {
  azs      = ["eu-south-2a", "eu-south-2b"] # MAX 2 AZ (dev)
  
  vpc_name     = var.vpc_name
  cidr_block   = "10.0.0.0/23"
  cidr_private = ["10.0.0.0/25", "10.0.0.128/25"]
  cidr_public  = ["10.0.1.0/25", "10.0.1.128/25"]
}

# define vpc with both public and private subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.vpc_name
  cidr = local.cidr_block

  azs             = local.azs
  private_subnets = local.cidr_private
  public_subnets  = local.cidr_public

  enable_nat_gateway      = true
  single_nat_gateway      = false
  one_nat_gateway_per_az  = true
  enable_vpn_gateway      = false
  enable_dns_hostnames    = true
  enable_dns_support      = true

  tags = var.tags
}