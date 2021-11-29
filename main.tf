provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "vpc-dev" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name= "demo-vpc"
    }
}
resource "aws_subnet" "snet1-dev" {
  vpc_id = aws_vpc.vpc-dev.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  tags = {
    "Name" = "demo-subnet1"
  }
}
resource "aws_subnet" "snet2-dev" {
  vpc_id = aws_vpc.vpc-dev.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  tags = {
    "Name" = "demo-subnet2"
  }
}

resource "aws_security_group" "sg-dev" {
  name = "demo-sg"
  vpc_id = aws_vpc.vpc-dev.id
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSH login"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}