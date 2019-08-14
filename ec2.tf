resource "aws_instance" "Bastion" {
  ami                     = "${var.bastion["ami"]}"
  instance_type           = "${var.bastion["type"]}"
  disable_api_termination = false
  key_name                = "${var.ec2_keypair}"
  count                   = "${var.bastion["count"]}"
  subnet_id               = "${element(aws_subnet.PublicSubnet.*.id, count.index)}"
  vpc_security_group_ids  = ["${aws_security_group.bastion_sg.id}"]
  #user_data               = "${file("${path.cwd}/install-ansible.sh")}"
  tags = {
    Name                  = "bastion-${count.index}.${var.environment_tag}"
    Environment           = "${var.environment_tag}"
  }
}
resource "aws_eip" "BastionPublicIP" {
    count    = "${var.bastion["count"]}"
    instance = "${element(aws_instance.Bastion.*.id,count.index)}"
    vpc = true
}
resource "aws_instance" "Master" {
  ami                     = "${var.master["ami"]}"
  instance_type           = "${var.master["type"]}"
  disable_api_termination = false
  key_name                = "${var.ec2_keypair}"
  count                   = "${var.master["count"]}"
  subnet_id               = "${element(aws_subnet.PrivateSubnet.*.id, count.index)}"
  vpc_security_group_ids  = ["${aws_security_group.stack_sg.id}"]
  tags = {
    Name                  = "master-${count.index}.${var.environment_tag}"
    Environment           = "${var.environment_tag}"
  }
}
resource "aws_instance" "Worker" {
  ami                     = "${var.worker["ami"]}"
  instance_type           = "${var.worker["type"]}"
  disable_api_termination = false
  key_name                = "${var.ec2_keypair}"
  count                   = "${var.worker["count"]}"
  subnet_id               = "${element(aws_subnet.PrivateSubnet.*.id, count.index)}"
  vpc_security_group_ids  = ["${aws_security_group.stack_sg.id}"]
  tags = {
    Name                  = "worker-${count.index}.${var.environment_tag}"
    Environment           = "${var.environment_tag}"
  }
}