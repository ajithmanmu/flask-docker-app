provider "aws" {
  region = "us-east-2" # Ensure this matches your desired region
}

# Import or define the existing key pair
resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"                # Name for the key pair in AWS
  public_key = file("~/.ssh/id_rsa.pub")     # Use your existing public key
}

# Security group to allow SSH and HTTP traffic
resource "aws_security_group" "flask_sg" {
  name        = "flask-security-group"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22                         # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]              # Adjust to your IP for better security
  }

  ingress {
    from_port   = 5000                       # Flask app
    to_port     = 5000
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

# EC2 instance configuration
resource "aws_instance" "flask_instance" {
  ami           = "ami-0a91cd140a1fc148a"    # Ubuntu AMI for us-east-2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name
  security_groups = [
    aws_security_group.flask_sg.name
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"                   # Default user for Ubuntu AMI
    private_key = file("~/.ssh/id_rsa")      # Path to your private key
    host        = self.public_ip             # Use the dynamic public IP
    timeout     = "5m"                       # Increase timeout if needed
  }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update -y",             # Update package manager
#       "sudo apt-get install docker.io -y", # Install Docker
#       "sudo systemctl start docker",       # Start Docker service
#       "sudo docker run -d -p 5000:5000 flask-docker-app" # Run your Flask app
#     ]
#   }
provisioner "remote-exec" {
  inline = [
    "sudo apt-get update -y",
    "sudo apt-get install docker.io -y",
    "sudo systemctl start docker",
    "sudo docker pull ajithmanmadhangeneral/flask-docker-app:latest",
    "sudo docker run -d -p 5000:5000 ajithmanmadhangeneral/flask-docker-app:latest"
  ]
}

  tags = {
    Name = "FlaskApp"
  }
}

# Output the instance's public IP
output "flask_app_public_ip" {
  value       = aws_instance.flask_instance.public_ip
  description = "Public IP of the Flask application"
}