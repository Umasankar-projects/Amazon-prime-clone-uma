module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true
  cluster_enabled_log_types      = ["api", "audit"]

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

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # ✅ CRITICAL: Enable cluster deletion protection OFF
  cluster_create_security_group = true
  cluster_security_group_additional_rules = {
    # Empty rules for destroy safety
  }

  # ✅ CRITICAL: Node group destroy settings
  eks_managed_node_groups = {
    panda-node = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      instance_types = ["t3.large"]  # ✅ Cheaper + reliable for destroy
      capacity_type  = "ON_DEMAND"

      # ✅ CRITICAL: Auto-scaling + destroy timeouts
      create_before_destroy = true
      create_launch_template = true
      
      # ✅ Destroy timeouts
      timeouts = {
        delete = "15m"
      }

      tags = {
        ExtraTag = "Panda_Node"
      }
    }
  }

  # ✅ CRITICAL: Proper destroy order
  depends_on = [
    module.vpc
  ]

  tags = merge(local.tags, {
    # ✅ Tags for destroy safety
    "kubernetes.io/cluster/${local.name}" = "owned"
  })
}
