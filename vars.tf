variable "aws_access_key" {
  description = "Please enter your access key"
  type = string
}

variable "aws_secret_key" {
    description = "Please enter your secret key"
    type = string
}

variable "aws_region" {
    default = "ap-south-1" 
}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {
  type = list 
}
variable "subnet_az" {
    type = list  
}

variable "aws_ins_ami" {
  type = string
}

variable "aws_instance_type" {}