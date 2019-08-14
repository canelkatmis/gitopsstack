variable "region" {
  description = "AWS region to work on"
  default     = "eu-central-1"
}
variable "environment_tag" {
  description = "An environment tag to use in every resource"
  default     = "canstack"
}
variable "vpc_cidr" {
  description = "VPC Network CIDR like 172.22.0.0/16, 10.0.0.0/16"
  default     = "10.14.0.0/16"
}
variable "public_subnets" {
  description = "Public Subnet"
  default     = [ "10.14.0.0/24", "10.14.1.0/24", "10.14.2.0/24" ]
}
variable "private_subnets" {
  description = "Private Subnet"
  default     = [ "10.14.10.0/24", "10.14.11.0/24", "10.14.12.0/24" ]
}
variable "ec2_keypair" {
  description = "The name of keypair that you need while logging via SSH"
  default     = "canstack"
}
variable "ec2_username" {
  description = "The name of user that you need while logging via SSH"
  default     = "ubuntu"
}
variable "bastion" {
  default = {
    count     = "1"
    ami       = "ami-0085d4f8878cddc81" #ubuntu16
    type      = "t2.micro"
  }
}
variable "master" {
  default = {
    count     = "1"
    ami       = "ami-0085d4f8878cddc81"
    type      = "t2.micro"
  }
}
variable "worker" {
  default = {
    count     = "3"
    ami       = "ami-0085d4f8878cddc81"
    type      = "t2.micro"
  }
}
