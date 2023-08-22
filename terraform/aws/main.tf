terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Create VPC
resource "aws_vpc" "lotus-full-node-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "lotus-full-node-vpc"
  }
}

#Create Public Subnet
resource "aws_subnet" "lotus-full-node-public" {
  vpc_id            = aws_vpc.lotus-full-node-vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "lotus-full-node-public"
  }
}

#Create Private Subnet
resource "aws_subnet" "lotus-full-node-private" {
  vpc_id            = aws_vpc.lotus-full-node-vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "lotus-full-node-private"
  }
}

#Create internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.lotus-full-node-vpc.id

  tags = {
    Name = "lotus-full-node-igw"
  }
}

#Create Route Table
resource "aws_route_table" "lotus-full-node-public-rt" {
  vpc_id = aws_vpc.lotus-full-node-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

#Associate Route Table to Subnet
resource "aws_route_table_association" "lotus-full-node" {
  subnet_id      = aws_subnet.lotus-full-node-public.id
  route_table_id = aws_route_table.lotus-full-node-public-rt.id

}


#Create Security Group
resource "aws_security_group" "lotus-full-node-sg" {
  vpc_id = aws_vpc.lotus-full-node-vpc.id

  name        = "lotus-full-node-sg"
  description = "Security Group for Lotus Full Node"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#Create the EC2 Instance
resource "aws_instance" "lotus-full-node" {
  ami               = "ami-053b0d53c279acc90"
  instance_type     = "r6idn.8xlarge"
  subnet_id         = aws_subnet.lotus-full-node-private.id
  availability_zone = "us-east-1a"

  vpc_security_group_ids = [
    aws_security_group.lotus-full-node-sg.id,
  ]

  tags = {
    Terraform = "true"
    Name      = "lotus-full-node"
  }
}

#Create EBS Volume
resource "aws_ebs_volume" "lotus-full-node" {
  availability_zone = "us-east-1a"
  size              = "5000"
  type              = "gp2"

  tags = {
    Name = "lotus-full-node-volume"
  }

  lifecycle {
    prevent_destroy = false
    # ignore_changes  = [lotus-full-node]
  }
}

#Attach EBS Volume
resource "aws_volume_attachment" "lotus-full-node" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.lotus-full-node.id
  instance_id  = aws_instance.lotus-full-node.id
  force_detach = false
}

