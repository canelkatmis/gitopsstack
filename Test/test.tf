provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "canelkatmis"
    workspaces {
      name = "canetest"
    }
  }
}

resource "aws_vpc" "VPC" {
  cidr_block           = "192.168.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "cane.test.vpc"
  }
}
