provider "aws" {
  region = "us-east-2" # Change to your preferred region
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "flask_sg" {
  name        = "flask-security-group"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "flask_instance" {
  ami           = "ami-0a91cd140a1fc148a" # Use the correct AMI ID for your region
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name
  security_groups = [
    aws_security_group.flask_sg.name
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user" # Default user for Amazon Linux 2
    private_key = file("~/.ssh/id_rsa") # Path to your private key
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install docker -y",
      "sudo service docker start",
      "docker run -d -p 5000:5000 flask-docker-app"
    ]
  }

  tags = {
    Name = "FlaskApp"
  }
}
