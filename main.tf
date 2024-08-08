provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  
  public_subnets  = ["10.0.1.0/24"]
  
  private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
}

resource "aws_instance" "ec2-example" {
  count = 2

  ami           = "ami-05c3dc660cb6907f0"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnets[count.index]
}
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"

  subnets            = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1]
  ]

  enable_deletion_protection = true
}
