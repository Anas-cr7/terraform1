provider "aws" {
  region = "us-east-1"  
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"  

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"  
  availability_zone       = "us-east-1a"   

  map_public_ip_on_launch = true

  tags = {
    Name = "MySubnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIGW"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "MyRouteTable"
  }
}

resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_security_group" {
  name        = "MySecurityGroup"
  description = "Security group allowing SSH, HTTP, and HTTPS traffic"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}

resource "aws_network_interface" "my_network_interface" {
  subnet_id          = aws_subnet.my_subnet.id
  private_ips        = ["10.0.1.10"]

  security_groups = [aws_security_group.my_security_group.id]

  tags = {
    Name = "MyNetworkInterface"
  }
}
resource "aws_instance" "my_instance" {
  ami           = "ami-0fc5d935ebf8bc3bc"  
  instance_type = "t2.micro"
  key_name      = "linuxx"    
  subnet_id     = aws_subnet.my_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "Ubuntu instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2
              EOF
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "anas07sana"
  acl = "private"  
}
resource "aws_dynamodb_table" "terraform-db" {
  name = "Terraform-db"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
terraform {
  backend "s3" {
    bucket = "anas07sana"
    dynamodb_table = "Terraform-db"
    key = "terraform.tfstate"
    region = "us-east-1"
    
  }
}