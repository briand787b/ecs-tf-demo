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
  source = "./modules/microservices/network"
}

# module "hello-world" {
#   source = "./modules/hello-world"
# }

# module "network" {
#   source = "./modules/network"

#   availability_zone_names = data.aws_availability_zones.available.names
# }

# module "ecs" {
#   source = "./modules/ecs"

#   vpc_id = module.network.vpc_id
#   public_subnets = "${module.network.private_subnets}"
#   private_subnets = "${module.network.public_subnets}"
# }
