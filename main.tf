terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}



# Security group to allow SSH and HTTP
resource "aws_security_group" "apache_sg" {
  name        = "apache-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance with Apache (Ansible master)
resource "aws_instance" "apache_server" {
  ami                         = data.aws_ami.ubuntu.id # Update if needed
  instance_type               = "t2.micro"
  key_name                    = "Linux1" # Ensure this key pair exists in ap-south-1
  vpc_security_group_ids      = [aws_security_group.apache_sg.id]
  subnet_id                   = data.aws_subnet.selected.id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/ansible.sh")

  tags = {
    Name        = "ansible master"
    Environment = "dev"
  }
}
