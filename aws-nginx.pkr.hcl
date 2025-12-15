packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0d50cd97bcf1ac9f1"
}

source "amazon-ebs" "nginx-image" {
  # AWS Configuration
  region = var.aws_region
  
  # AMI Configuration
  ami_name      = "packer-nginx-class-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  instance_type = "t2.micro"
  
  # SSH Configuration (Standard for Amazon Linux)
  ssh_username = "ec2-user"

  # Network Configuration for the Build Instance
  vpc_id = var.vpc_id
  
  # This filter automatically finds a Public Subnet in your VPC
  subnet_filter {
    filters = {
      "vpc-id": var.vpc_id,
      "mapPublicIpOnLaunch": "true"
    }
    most_free = true
    random    = true
  }

  # Source AMI Filter (Amazon Linux 2023)
  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.nginx-image"
  ]

  # Upload the HTML file to the temporary instance
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }

  # Run the setup script to install Nginx and configure everything
  provisioner "shell" {
    script = "setup.sh"
  }
}