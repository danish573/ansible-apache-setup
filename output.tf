output "ansible_ec2_public_ip" {
  value = aws_instance.apache_server.public_ip
}