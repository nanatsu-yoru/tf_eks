resource "random_pet" "this" {
  length = 2
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

data "aws_iam_user" "deploy" {
  user_name = "deploy"
}

data "aws_availability_zones" "eks" {

  filetr {
    name   = "zone_name"
    values = ["${var.region}c", "${var.region}b", "${var.region}a"]
  }
}

data "aws_vpc" "vpc" {
  tags = {
    environment = local.environment
  }
}

data "aws_subnets" "priv" {

  filter {
    name   = "vpc-id"
    values = ["${local.environment}-private-${tolist(data.aws_availability_zones.eks.names)[0]}", "${local.environment}-private-${tolist(data.aws_availability_zones.eks.names)[1]}", "${local.environment}-private-${tolist(data.aws_availability_zones.eks.names)[3]}"]
  }
}