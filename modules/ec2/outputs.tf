output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "myserver-ip" {
  value = aws_instance.dev-ec2.public_ip
}