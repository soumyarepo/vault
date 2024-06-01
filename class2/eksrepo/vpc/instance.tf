provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-0f5ee92e2d63afc18"
    instance_type = "t2.micro"
    key_name = "terraform"
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    subnet_id = aws_subnet.my-public-subnet-1.id
}

resource "aws_security_group" "demo-sg" {
  name_prefix = "demo-sg"
  description = "Example security group for SSH and HTTP"
  vpc_id = aws_vpc.my-vpc.id
  

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "JENKINSPORT"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "SSH"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "my-vpc"
  }

}

resource "aws_subnet" "my-public-subnet-1" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "my-public-subnet-1"
  }
}

resource "aws_subnet" "my-public-subnet-2" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "my-public-subnet-2"
  }
}

resource "aws_internet_gateway" "my-igt" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-igt"
  }
}

resource "aws_route_table" "my-public-igt" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-public-igt"
  }
}

resource "aws_route" "my-route" {
  route_table_id         = aws_route_table.my-public-igt.id
  destination_cidr_block = "0.0.0.0/0"  # Route all traffic (Internet)
  gateway_id             = aws_internet_gateway.my-igt.id
}

resource "aws_route_table_association" "my-rta-public-1" {
  subnet_id = aws_subnet.my-public-subnet-1.id
  route_table_id = aws_route_table.my-public-igt.id
}

resource "aws_route_table_association" "my-rta-public-2" {
  subnet_id = aws_subnet.my-public-subnet-2.id
  route_table_id = aws_route_table.my-public-igt.id
}

module "sgs" {
  source = "../sg_eks"
   vpc_id  =  aws_vpc.my-vpc.id
}

module "eks" {
   source = "../eks"
    vpc_id  =  aws_vpc.my-vpc.id
    subnet_ids = [aws_subnet.my-public-subnet-1.id,aws_subnet.my-public-subnet-2.id]
   sg_ids = module.sgs.security_group_public
}