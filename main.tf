provider "aws" {
  region = "us-east-2"
}

variable cidr_blocks {}
variable env {}
variable instance_type {}
variable "avail_zone" {}
variable "public_key"{}
variable "private_key"{}

resource "aws_vpc" "vpc-dev" {
    cidr_block = var.cidr_blocks[0]
    tags = {
        Name= "${var.env}-vpc"

    }
}

resource "aws_subnet" "snet1-dev" {
  vpc_id = aws_vpc.vpc-dev.id
  cidr_block = var.cidr_blocks[1]
  availability_zone = var.avail_zone
  tags = {
    "Name" = "${var.env}-subnet1"
  }
}

resource "aws_subnet" "snet2-dev" {
  vpc_id = aws_vpc.vpc-dev.id
  cidr_block = var.cidr_blocks[2]
  availability_zone = "us-east-2b"
  tags = {
    "Name" = "${var.env}-subnet2"
  }
}

output "vpc" {
  value = aws_vpc.vpc-dev.id
  
}

output "subnet-1" {
  value = aws_subnet.snet1-dev.id
}

/*
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
*/

resource "aws_default_security_group" "sg-dev"{
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
  tags = {
    Name= "${var.env}-sg"
  }
}


resource "aws_internet_gateway" "ig-dev"{
vpc_id = aws_vpc.vpc-dev.id
tags={
  Name = "${var.env}-ig"
}

}
/*
resource "aws_route_table" "it-dev"{
  vpc_id = aws_vpc.vpc-dev.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-dev.id
  }
  tags ={
    Name = "demo-it"
  }
} */

resource "aws_default_route_table" "rt-dev"{
  default_route_table_id = aws_vpc.vpc-dev.main_route_table_id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-dev.id
  }
  tags = {
    Name = "${var.env}-rt"
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ami_id" {
  value = data.aws_ami.ubuntu.id
}
resource "aws_key_pair" "dev-key" {
  key_name = "master"
  public_key = "${file(var.public_key)}"
}

resource "aws_instance" "dev-ec2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_default_security_group.sg-dev.id]
  subnet_id = aws_subnet.snet1-dev.id
  availability_zone = var.avail_zone
  tags = {
    "Name" = "${var.env}-server"
  }
   connection {
     type = "ssh"
     host = self.public_ip
     user = "ubuntu"
     private_key = file(var.private_key)
   }

   provisioner "file" {
     source = "/Users/gopi/sessions/terraform/terraform/entry-script.sh"
     destination = "/home/ubuntu/entry-on-ec2-script.sh"
   
   }
   provisioner "remote-exec" {
       inline = [
       "touch /home/ubuntu/Mark.txt",
       "mkidr /home/ubuntu/Mark-FOlder"

       ]
   }

   provisioner "local-exec" {
       command = "echo ${self.public_ip} > ip.txt"
   }
  
}

output "myserver-ip" {
  value = aws_instance.dev-ec2.public_ip
}