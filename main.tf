provider "aws" {
  region = "us-east-2"
}


/*
resource "aws_vpc" "vpc-dev" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name= "${var.env}-vpc"

    }
}

module "mynet" {
  source = "./modules/networking"
  vpc_id = aws_vpc.vpc-dev.id
  m_subnet_cidr_block = var.subnet_cidr_block
  m_avail_zone = var.avail_zone
  m_env = var.env
  m_default_rt_id = aws_vpc.vpc-dev.default_route_table_id 
}
*/

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

  name = "vpc-dev"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = [var.subnet_cidr_block]



  tags = {
     Name= "${var.env}-vpc"
  }
}
  
module "instance" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  env = var.env
  public_key = var.public_key
  avail_zone = var.avail_zone
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  
}









