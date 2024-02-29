terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.37.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region
}

# create a vpc 
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Vpc1"
  }
}

# create a Subnet1 for Public Puropse
resource "aws_subnet" "subnet1" {
    vpc_id = aws_vpc.vpc1.id
    cidr_block = var.subnet_cidr_block[0]
    availability_zone = var.subnet_az[0]
    map_public_ip_on_launch = "true"
    tags = {
        Name = "Vpc1_subnet1_public_az1"
    }
}

# create a Subnet2 for Private Puropse
resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.vpc1.id
    cidr_block = var.subnet_cidr_block[1]
    availability_zone = var.subnet_az[1]
    tags = {
        Name = "Vpc1_subnet2_private_az2"
    }
}

# create a Subnet3 for Private Puropse
resource "aws_subnet" "subnet3" {
    vpc_id = aws_vpc.vpc1.id
    cidr_block = var.subnet_cidr_block[2]
    availability_zone = var.subnet_az[0]
    tags = {
        Name = "Vpc1_subnet3_private_az1"
    }
}

# create a Subnet4 for Public Puropse
resource "aws_subnet" "subnet4" {
    vpc_id = aws_vpc.vpc1.id
    cidr_block = var.subnet_cidr_block[3]
    availability_zone = var.subnet_az[1]
    map_public_ip_on_launch = "true"
    tags = {
        Name = "Vpc1_subnet4_public_az2"
    }
}

# crate a internet gateway for vpc1 
resource "aws_internet_gateway" "vpc1igw" {
     vpc_id = aws_vpc.vpc1.id
     tags = {
        Name = "vpc1_internet_gateway"
     }
}   

# create a eip for nat gateway 
resource "aws_eip" "nateip" {
   domain = "vpc"
   
}
# create a nat gateway in vpc 
resource "aws_nat_gateway" "natgwvpc" {
  allocation_id = aws_eip.nateip.id
  subnet_id = aws_subnet.subnet1.id
  depends_on = [ aws_eip.nateip ]
  tags = {
    Name = "vpc1_nat_gateway"
  }
}


resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1igw.id
  } 
}

resource "aws_route_table" "privatecrt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgwvpc.id
  } 
}

resource "aws_route_table_association" "assosiatepublicsubnet" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table_association" "assosiatepublicsubnet2" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table_association" "assosiateprivatesubnet" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.privatecrt.id
}

resource "aws_route_table_association" "assosiateprivatesubnet2" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.privatecrt.id
}

# create Instance security Group 
resource "aws_security_group" "secgrpins1"{
   name = "Terraform_vpc_sg"
   vpc_id = aws_vpc.vpc1.id
   description = "Terraform created security group"

ingress {
    from_port = 22
    to_port   = 22
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
   }

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
}
}

resource "aws_instance" "ins1" {
     ami = var.aws_ins_ami
     instance_type = var.aws_instance_type
     key_name = aws_key_pair.ins1_key_pair.key_name
     subnet_id = aws_subnet.subnet1.id
     security_groups = [aws_security_group.secgrpins1.id]

     tags = {
      Name = "Terraform_based_Ins"
     }
}

# Create Key Using tls_Private_key
resource "tls_private_key" "ins1_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ins1_key_pair" {
  key_name   =  "ins1"
  public_key = tls_private_key.ins1_key.public_key_openssh
}

resource "local_file" "ins1" {
   filename = "ins1.pem"
   content = tls_private_key.ins1_key.private_key_pem
}

output "private_key" {
 value = tls_private_key.ins1_key.private_key_pem
 sensitive = true 
}
