module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  name    = "main"
  cidr    = "10.0.0.0/16"

  azs                     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  map_public_ip_on_launch = true
  enable_nat_gateway      = true
  one_nat_gateway_per_az  = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
