output "flask_app_public_ip" {
  value = aws_instance.flask_instance.public_ip
  description = "Public IP of the Flask application"
}