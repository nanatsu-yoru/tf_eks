module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 19.13.1"
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  #no proper SGs yet
  cluster_endpoint_public_access = true
  create_cloudwatch_log_group    = true
  cluster_enabled_log_types      = []

  cluster_addons = {
    coredns = {
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      most-recent              = true
      preserve                 = true
    }
    kube-proxy = {
      most_recent = true
      preserve    = true
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.es_csi_irsa_role.iam_role_arn
      most_recent              = true
      preserve                 = true
    }
    vpc-cni = {
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      most_recent              = true
      preserve                 = true
    }
  }

  #encryption
  create_kms_key = true

  cluster_encryption_config = {
    resources = ["secrets"]
  }
  enable_kms_key_rotation = true
  kms_key_administrators  = ["*"]

  vpc_id                   = data.aws_vpc.vpc.id
  subnet_ids               = data.aws_subnets.priv.ids
  control_plane_subnet_ids = data.aws_subnets.priv.ids


  create_cni_ipv6_iam_policy            = true
  create_cluster_security_group         = true
  cluster_additional_security_group_ids = [module.sg.eks.cluster_additional_security_group_id]

  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description = "https"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cid_blocks  = ["10.0.0.0/8"]
      type        = "ingress"
    }
    egress_nodes_ephemeral_ports_tcp = {
      description = "Nodes | 1025-65535"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      cidr_blocks = ["10.0.0.0/8"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                              = "BOTTLEROCKET_x86_64"
    disk_size                             = 50
    instance_types                        = ["m5.xlarge", "m5.large", "t3a.small", "t3a.xlarge"]
    iam_role_attach_cni_policy            = true
    attach_cluster_primary_security_group = true
    vpc_security_group_ids                = ["${module.sg_eks_additional.security_group_id}"]
    metadata_optins = {
      http_endpoint               = "enabled"
      http_tokens                 = "optional"
      http_put_response_hop_limit = 2
    }
  }

  # configmap
  manage_aws_auth_configmap = true

  aws_auth_node_iam_role_arns_non_windows = [
    module.eks_managed_node_group.iam_role_arn
  ]

  aws_auth_users = [

  ]

  tags = merge(
    {
      Name = local.cluster_name
    },
    # lookup(local.tags, "general", {})
  )

}