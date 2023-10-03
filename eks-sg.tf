module "sg_eks" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "eks-acc-${var.cluster_name}"
  description = "Cluster access SG"

  vpc_id              = data.aws_vpc.vpc.id
  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]

  egress_rules = ["all-all"]
  tags = merge(
    {
      env = "${local.environment}"
    },
    lookup(local.tags, "general", {})
  )
}

module "sg_eks_additional" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "eks-additional-${var.cluster_name}"
  description = "Additional access SG"

  vpc_id              = data.aws_vpc.vpc.id
  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["ssh-tcp"]

  egress_rules = ["all-all"]
  tags = merge(
    {
      env = "${local.environment}"
    },
    lookup(local.tags, "general", {})
  )
}