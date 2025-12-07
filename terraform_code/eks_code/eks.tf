 module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"  # Your original working version

  cluster_name                   = local.name
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = ["api", "audit"]  # Required in v19

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  cluster_security_group_additional_rules = {}  # Required empty block

  eks_managed_node_groups = {
    panda-node = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      instance_types = ["c7i-flex.large"]  # Valid instance type
      capacity_type  = "ON_DEMAND"

      tags = {
        ExtraTag = "Panda_Node"
      }
    }
  }

  tags = local.tags
}
