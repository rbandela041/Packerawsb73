# Packerawsb73
Deploying ami using packer in aws
# AWS Packer Nginx Class Project

## Code Explanation: aws-nginx.pkr.hcl

### 1. Packer Block
```hcl
packer {
  required_plugins {
    amazon = { ... }
  }
}
```
What it does: Tells Packer we need the "Amazon" plugin to talk to AWS. It downloads the code necessary to create EC2 instances and AMIs.

## Variables
variable "vpc_id" {
  default = "vpc-0d50cdxxxxxxxx"
}

### What it does: Defines inputs. We hardcoded your specific VPC ID here so Packer knows where to launch the temporary build server.

## Source Block (amazon - ebs)

ami_name: Sets the name of the final image. We use formatdate and timestamp to ensure the name is unique every time you run it (e.g., packer-nginx-class-20231025120000).

instance_type: We use t2.micro (free tier eligible) to build the image.

ssh_username: Tells Packer to log in as ec2-user, which is the default user for Amazon Linux.

vpc_id: Uses the variable we defined earlier.

subnet_filter:

This is a smart block. Instead of hardcoding a Subnet ID, it asks AWS: "Find me a subnet in my VPC that allows public IPs." This ensures Packer can connect to the server via SSH to run your scripts.

source_ami_filter:

name = "al2023-ami-2023.*-x86_64": Looks for the latest Amazon Linux 2023 image.

owners = ["amazon"]: Ensures we only trust official images from Amazon.

4. Build Block
Terraform
```
build {
  sources = ["source.amazon-ebs.nginx-image"]
}
```

What it does: This is the execution phase. It tells Packer to start the EC2 instance defined in the source block above.

# Provisioners
Provisioners are the steps Packer takes inside the server while it is running.

## File Provisioner:

Terraform

```
provisioner "file" {
  source      = "index.html"
  destination = "/tmp/index.html"
}
```

Explanation: Uploads your local index.html (the one with the cool GIF) to the /tmp folder on the AWS server.

## Shell Provisioner:

Terraform
```
provisioner "shell" {
  script = "setup.sh"
}
```
Explanation: Runs the setup.sh script on the server. This script:

Installs Nginx.

Moves the index.html from /tmp to /usr/share/nginx/html (where web servers live).

Injects your specific public SSH key (testppkkey) into the server so you can log in later.