# resource "aws_lb" "master_alb" {
#   name               = "master-alb"
#   internal           = false
#   load_balancer_type = "network"
#   subnets            = "${aws_subnet.PublicSubnet.*.id}"
#   enable_cross_zone_load_balancing  = true
#   tags = {
#     Name                  = "master_alb.${var.environment_tag}"
#     Environment           = "${var.environment_tag}"
#   }
# }
# resource "aws_lb" "worker_alb" {
#   name            = "worker-alb"
#   subnets         = "${aws_subnet.PublicSubnet.*.id}"
#   security_groups = ["${aws_security_group.worker_alb_sg.id}"]
#   internal        = false
#   idle_timeout    = 60
#   tags = {
#     Name                  = "worker_alb.${var.environment_tag}"
#     Environment           = "${var.environment_tag}"
#   }
# }
# resource "aws_lb_target_group" "group_master_alb" {
#   name     = "master-alb-target-group"
#   port     = "8443"
#   protocol = "TCP"
#   vpc_id   = "${aws_vpc.VPC.id}"
#   tags = {
#     Name                  = "master-alb-target-group.${var.environment_tag}"
#     Environment           = "${var.environment_tag}"
#   }
# }
# resource "aws_lb_target_group" "group_worker_alb" {
#   name     = "worker-alb-target-group"
#   port     = "80"
#   protocol = "HTTP"
#   vpc_id   = "${aws_vpc.VPC.id}"
#   stickiness {
#     type            = "lb_cookie"
#     cookie_duration = 1800
#     enabled         = true
#   }
#   health_check {
#     healthy_threshold   = 3
#     unhealthy_threshold = 10
#     timeout             = 5
#     interval            = 10
#     path                = "/"
#     port                = 80
#   }
#   tags = {
#     Name                  = "worker-alb-target-group.${var.environment_tag}"
#     Environment           = "${var.environment_tag}"
#   }
# }
# resource "aws_lb_listener" "listener_master_alb" {
#   load_balancer_arn = "${aws_lb.master_alb.arn}"
#   port              = 8443
#   protocol          = "TCP"
#   default_action {
#     target_group_arn = "${aws_lb_target_group.group_master_alb.arn}"
#     type             = "forward"
#   }
# }
# resource "aws_lb_listener" "listener_worker_alb" {
#   load_balancer_arn = "${aws_lb.worker_alb.arn}"
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     target_group_arn = "${aws_lb_target_group.group_worker_alb.arn}"
#     type             = "forward"
#   }
# }
# resource "aws_lb_target_group_attachment" "attachment_master_ec2" {
#   count            = "${var.master["count"]}"
#   target_group_arn = "${aws_lb_target_group.group_master_alb.arn}"
#   target_id        = "${element(aws_instance.Master.*.id, count.index)}"
#   port             = 8443
# }

# resource "aws_lb_target_group_attachment" "attachment_worker_ec2" {
#   count            = "${var.worker["count"]}"
#   target_group_arn = "${aws_lb_target_group.group_worker_alb.arn}"
#   target_id        = "${element(aws_instance.Worker.*.id, count.index)}"
#   port             = 80
# }
