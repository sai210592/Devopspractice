provider "aws" {

  region = "ap-south-1"

}

resource "aws_vpc" "dpps_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dpps_vpc"
  }
}
resource "aws_subnet" "dpps_public_subnet_01" {
  vpc_id                  = aws_vpc.dpps_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "dpps_public_subent_01"
  }
}

resource "aws_subnet" "dpps_public_subnet_02" {
  vpc_id                  = aws_vpc.dpps_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "dpps_public_subnet_02"
  }

}

resource "aws_internet_gateway" "dpps_igw" {
  vpc_id = aws_vpc.dpps_vpc.id

  tags = {
    Name = "dpps_igw"
  }
}
resource "aws_route_table" "dpps_rt" {
  vpc_id = aws_vpc.dpps_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpps_igw.id
  }

  tags = {
    Name = "dpps_rt01"
  }
}

resource "aws_route_table_association" "dpps_rt_public_subnet_01" {
  subnet_id      = aws_subnet.dpps_public_subnet_01.id
  route_table_id = aws_route_table.dpps_rt.id
}

resource "aws_route_table_association" "dpps_rt_public_subnet_02" {
  subnet_id      = aws_subnet.dpps_public_subnet_02.id
  route_table_id = aws_route_table.dpps_rt.id
}

resource "aws_instance" "new_instance" {

  ami                    = "ami-04a37924ffe27da53"
  instance_type          = "t2.micro"
  key_name               = "dpps"
  vpc_security_group_ids = [aws_security_group.dpps-sg.id]
  subnet_id              = aws_subnet.dpps_public_subnet_01.id

}

resource "aws_security_group" "dpps-sg" {
  name        = "dpps-sg"
  description = "SSH Access"
  vpc_id      = aws_vpc.dpps_vpc.id

  ingress {
    description = "Shh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-prot"

  }
}
