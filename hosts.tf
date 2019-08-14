resource "local_file" "render_hosts" {
  content = templatefile( "scripts/ansible-hosts.tmpl", {
    bastion_hosts = "${join("\n", "${aws_instance.Bastion.*.private_ip}")}"
    master_hosts = "${join("\n", "${aws_instance.Master.*.private_ip}")}"
    worker_hosts = "${join("\n", "${aws_instance.Worker.*.private_ip}")}"
    ec2_keypair = "${var.ec2_keypair}"
    ec2_username = "${var.ec2_username}"
  })
  filename = "${path.cwd}/scripts/ansible-hosts"
}

resource "null_resource" "after_rendering" {
  depends_on = ["local_file.render_hosts"]
  connection {
    type        = "ssh"
    user        = "${var.ec2_username}"
    private_key = "${file("${var.ec2_keypair}.pem")}"
    host        = "${aws_eip.BastionPublicIP.0.public_ip}"
    port        = "22"
  }

  provisioner "file" {
    source      = "scripts/install-ansible.sh"
    destination = "/home/ubuntu/install-ansible.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/install-ansible.sh",
      "/home/ubuntu/install-ansible.sh"
    ]
  }

  provisioner "file" {
    source      = "scripts/ansible-hosts"
    destination = "/home/ubuntu/ansible-hosts"
  }

  provisioner "file" {
    source      = "scripts/roles"
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    source      = "${var.ec2_keypair}.pem"
    destination = "/home/ubuntu/${var.ec2_keypair}.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ubuntu/${var.ec2_keypair}.pem"
    ]
  }

  provisioner "file" {
    source      = "scripts/install-k8s.yml"
    destination = "/home/ubuntu/install-k8s.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/install-k8s.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/ansible-hosts install-k8s.yml"
    ]
  }
}
