module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  # ✅ CRITICAL: Single NAT Gateway (faster destroy)
  enable_nat_gateway     = true
  single_nat_gateway     = true  # ✅ Faster destroy
  one_nat_gateway_per_az = false

  # ✅ Public subnet tags for ELB
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  # ✅ CRITICAL: Destroy timeouts
  manage_default_security_group = false
  manage_default_route_table    = true
  manage_default_network_acl    = true

  tags = merge(local.tags, {
    # ✅ Destroy safety tags
    "kubernetes.io/cluster/${local.name}" = "shared"
  })
}
