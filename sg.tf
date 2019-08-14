resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  vpc_id      = "${aws_vpc.VPC.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name            = "bastion_sg.${var.environment_tag}"
    Environment     = "${var.environment_tag}"
  }
}
resource "aws_security_group" "stack_sg" {
  name        = "stack_sg"
  vpc_id      = "${aws_vpc.VPC.id}"
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.master_alb_sg.id}"]
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.worker_alb_sg.id}"]
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.bastion_sg.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name            = "stack_sg.${var.environment_tag}"
    Environment     = "${var.environment_tag}"
  }
}
# resource "aws_security_group" "master_alb_sg" {
#   name = "master_alb_sg"
#   vpc_id      = "${aws_vpc.VPC.id}"

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port = 8443
#     to_port = 8443
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name            = "master_alb_sg.${var.environment_tag}"
#     Environment     = "${var.environment_tag}"
#   }
# }
# resource "aws_security_group" "worker_alb_sg" {
#   name = "worker_alb_sg"
#   vpc_id      = "${aws_vpc.VPC.id}"

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name            = "worker_alb_sg.${var.environment_tag}"
#     Environment     = "${var.environment_tag}"
#   }
# }