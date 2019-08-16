# terraform {
#   backend "remote" {
#     hostname = "app.terraform.io"
#     organization = "canelkatmis"

#     workspaces {
#       name = "canstack-tf-ws"
#     }
#   }
# }

provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "VPC" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "vpc.${var.environment_tag}"
    Environment = "${var.environment_tag}"
  }
}
resource "aws_subnet" "PublicSubnet" {
  vpc_id            = "${aws_vpc.VPC.id}"
  count             = "${length(var.public_subnets)}"
  cidr_block        = "${element(var.public_subnets, count.index % length(var.public_subnets))}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  tags = {
    Name        = "subnet-public-${count.index}.${var.environment_tag}"
    Environment = "${var.environment_tag}"
  }
}

resource "aws_subnet" "PrivateSubnet" {
  vpc_id            = "${aws_vpc.VPC.id}"
  count             = "${length(var.private_subnets)}"
  cidr_block        = "${element(var.private_subnets, count.index % length(var.private_subnets))}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  tags = {
    Name        = "subnet-private-${count.index}.${var.environment_tag}"
    Environment = "${var.environment_tag}"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = "${aws_vpc.VPC.id}"
  tags = {
    Name        = "igw.${var.environment_tag}"
    Environment = "${var.environment_tag}"
  }
}

resource "aws_route_table" "RT_PUB" {
  vpc_id = "${aws_vpc.VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IGW.id}"
  }
  tags = {
    Name        = "rt-pub.${var.environment_tag}"
    Environment = "${var.environment_tag}"
  }
}
resource "aws_route_table_association" "PubSubnetRT" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.PublicSubnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.RT_PUB.id}"
}
resource "aws_eip" "EIP" {
  count = "${length(var.private_subnets)}"
  vpc   = true
}
resource "aws_nat_gateway" "NatGW" {
  count         = "${length(var.private_subnets)}"
  allocation_id = "${element(aws_eip.EIP.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.PublicSubnet.*.id, count.index)}"
}

resource "aws_route_table" "RT_NAT" {
  vpc_id = "${aws_vpc.VPC.id}"
  count  = "${length(var.private_subnets)}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.NatGW.*.id, count.index)}"
  }
  tags = {
    Name        = "rt-nat-${count.index}.${var.environment_tag}"
    Environment = "${var.environment_tag}"
  }
}
resource "aws_route_table_association" "NatSubnetRT" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.PrivateSubnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.RT_NAT.*.id, count.index)}"
}
resource "aws_network_acl" "ACL" {
  vpc_id = "${aws_vpc.VPC.id}"
  subnet_ids = "${concat(aws_subnet.PublicSubnet.*.id,
  aws_subnet.PrivateSubnet.*.id)}"
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name        = "acl.${var.environment_tag}"
    Environment = "${var.environment_tag}"
  }
}
