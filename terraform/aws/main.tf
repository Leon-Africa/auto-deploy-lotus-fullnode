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
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

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
resource "aws_internet_gateway" "igw" {
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
    gateway_id = aws_internet_gateway.igw.id
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

#AWS SSM Role
resource "aws_iam_instance_profile" "ssm-profile" {
  name = "EC2SSM"
  role = aws_iam_role.ssm-role.name
}

resource "aws_iam_role" "ssm-role" {
  name               = "EC2SSM"
  description        = "EC2 SSM Role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF

  tags = {
    Name = "lotus-full-node"
  }
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
  role       = aws_iam_role.ssm-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3-policy" {
  role       = aws_iam_role.ssm-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2-policy" {
  role       = aws_iam_role.ssm-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}


#Create the EC2 Instance
resource "aws_instance" "lotus-full-node" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "r6i.xlarge"
  subnet_id                   = aws_subnet.lotus-full-node-public.id
  availability_zone           = "us-east-1a"
  iam_instance_profile        = aws_iam_instance_profile.ssm-profile.name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.lotus-full-node-sg.id,
  ]

  tags = {
    Terraform = "true"
    Name      = "lotus_full_node"
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

resource "aws_s3_bucket" "ssm-bucket" {
  bucket = "lotus-aws-ssm-connection-playbook"

  tags = {
    Name = "SSM Connection Bucket"
  }
}
