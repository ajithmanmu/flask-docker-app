# flask-docker-app

Flask App Deployment on AWS EC2 with Docker and Terraform

This project demonstrates deploying a Flask application on an AWS EC2 instance using Docker and Terraform. We built a Docker image for the Flask app, configured it to run on port 5000, and pushed it to Docker Hub. Using Terraform, we provisioned the AWS EC2 instance, created a security group allowing HTTP traffic on port 5000, and set up the Docker container to run the app. The Flask app is accessible via the public IPv4 address of the EC2 instance.

Important Note: Ensure the Docker image is built for multiple platforms (e.g., linux/amd64 and linux/arm64) using Docker Buildx to avoid compatibility issues between development and production environments. This ensures the image works seamlessly on EC2 instances, which typically use linux/amd64.
