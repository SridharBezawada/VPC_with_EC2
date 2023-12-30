provider "aws" {
  region = "var.location"  # Change this to your desired AWS region
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "var.cidr_block_VPC"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Attach Internet Gateway to VPC
resource "aws_internet_gateway_attachment" "my_igw_attachment" {
  vpc_id             = aws_vpc.my_vpc.id
  internet_gateway_id = aws_internet_gateway_attachment.my_igw_attachment.id
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "var.location"  # Change this to your desired availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "var.location"  # Change this to your desired availability zone

  tags = {
    Name = "Private Subnet"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  # description = "Allow inbound SSH and outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ec2_security_group"
  }
}

# EC2 Instance
resource "aws_instance" "my_instance" {
  ami             = "var.ami"  # Replace with your desired AMI ID
  instance_type   = "t2.micro"
  key_name        = "YourKeyPairName"  # Replace with your key pair name
  subnet_id       = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.ec2_security_group ]

  tags = {
    Name = "MyEC2Instance"
  }
}
