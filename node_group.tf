module "eks_managed_node_group" {
  source          = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version         = "~> 19.13.1"
  name            = "${local.account_name}-infra-${local.environment}"
  cluster_name    = module.eks.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = data.aws_subnets.priv.ids
  vpc_security_group_ids = [
    module.eks.cluster_primary_security_group_id,
    module.eks.cluster_security_group_id,
  ]
  # iam_role_additional_policies = {
  #     additional = aws_iam_policy.GrafanaCWPolicy.arn
  # }

  min_size     = 1
  max_size     = 2
  desired_size = 2

  disk_size      = "50"
  key_name       = "ubuntu"
  instance_types = ["t3a.xlarge"]
  capacity_type  = "ON_DEMAND"

  labels = {
    tier       = "infra"
    prometheus = "true"
    grafana    = "true"
    jaeger     = "true"
  }

  taints = {
    tier = {
      key    = "tier"
      value  = "infra"
      effect = "PREFER_NO_SCHEDULE"
    },
    prometeus = {
      key    = "prometheus"
      value  = "infra"
      effect = "PREFER_NO_SCHEDULE"
    },
    grafana = {
      key    = "grafana"
      value  = "true"
      effect = "PREFER_NO_SCHEDULE"
    },
    jaeger = {
      key    = "jaeger"
      value  = "true"
      effect = "PREFER_NO_SCHEDULE"
    }
  }

  tags = merge(
    {
      Name     = " Node group ${local.cluster_name}"
      NodeType = "infra"
    },
    # lookup(local.tags, "general", {}),
  )
}