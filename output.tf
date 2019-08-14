# Outputs
output "BastionPublicIP"       {
  value                       = ["${aws_eip.BastionPublicIP.*.public_ip}"]
}
output "BastionPrivateIP"       {
  value                       = ["${aws_instance.Bastion.*.private_ip}"]
}
output "MasterPrivateIPs"       {
  value                       = ["${aws_instance.Master.*.private_ip}"]
}
output "WorkerPrivateIPs"       {
  value                       = ["${aws_instance.Worker.*.private_ip}"]
}

