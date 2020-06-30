provider "aws" {
  profile = "sparkfly-dev"
  version = "~> 2.0"
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "sparkfly-dev-sandbox-terraform-state"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "sparkfly-dev"
  }
}

data "aws_availability_zones" "available" {}

module "network" {
  source = "./modules/network"
}

module "ecs" {
  source = "./modules/ecs"

  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids = module.network.public_subnet_ids
  sg_id = module.network.allow_all_sg_id
  vpc_id = module.network.vpc_id
  igw = module.network.igw
}

module "ec2" {
  source = "./modules/ec2"

  sg_id = module.network.allow_all_sg_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
}
