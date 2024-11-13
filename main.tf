# Initialize the AWS Provider
provider "aws" {
  region = "us-east-1" # N. Virginia
}

# VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "lab-vpc"
  }
}

# Subnet
resource "aws_subnet" "lab_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "lab-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id
  tags = {
    Name = "lab-igw"
  }
}

# Route Table
resource "aws_route_table" "lab_route_table" {
  vpc_id = aws_vpc.lab_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }
  tags = {
    Name = "lab-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "lab_route_table_association" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_route_table.id
}

# Security Group
resource "aws_security_group" "lab_sg" {
  vpc_id = aws_vpc.lab_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace "your-public-ip" with your actual IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "lab-sg"
  }
}

# EC2 Instance
resource "aws_instance" "vulnerable_server" {
  ami                         = "ami-0984f4b9e98be44bf"  # Amazon Linux 2 AMI (replace with the latest AMI ID)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.lab_subnet.id
  vpc_security_group_ids      = [aws_security_group.lab_sg.id]  # Use security group ID instead of name

  metadata_options {
    http_tokens               = "optional"  # IMDSv1
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "vulnerable-server"
  }

  # User Data to install httpd and download files
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    yum install -y php
    systemctl start httpd
    systemctl enable httpd

    # Download the PHP file from a public URL (like an S3 bucket or GitHub)
    wget -O /var/www/html/ssrf.php https://raw.githubusercontent.com/jasonYuRong/2019-AWS-Data-Breach-Demo/main/ssrf.php
    wget -O /var/www/html/code_rain.gif https://raw.githubusercontent.com/jasonYuRong/2019-AWS-Data-Breach-Demo/main/code_rain.gif
  EOF
}

# S3 Bucket
resource "aws_s3_bucket" "jhu_en_650_603" {
  bucket = "jhu-en-650-603"
  tags = {
    Name = "jhu_EN.650.603"
  }
}

# Add JSON File to S3 Using aws_s3_object
resource "aws_s3_object" "json_file" {
  bucket = aws_s3_bucket.jhu_en_650_603.bucket
  key    = "customer.json"  # The name of the file in the S3 bucket
  source = "./customer.json"  # Local path to the JSON file
  acl    = "private"  # Access control (e.g., private, public-read)
}