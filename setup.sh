#!/bin/bash

# 1. Update the system
sudo dnf update -y

# 2. Install Nginx
sudo dnf install nginx -y

# 3. Enable and start Nginx so it starts on boot
sudo systemctl enable nginx
sudo systemctl start nginx

# 4. Move our custom index.html to the web server directory
# We assume the file was uploaded to /tmp/index.html by Packer
sudo mv /tmp/index.html /usr/share/nginx/html/index.html

# 5. Set correct permissions
sudo chmod 644 /usr/share/nginx/html/index.html
sudo chown root:root /usr/share/nginx/html/index.html

# 6. Add your Public SSH Key to authorized_keys
# This allows you to SSH into the instance using your private key later
USER_SSH_DIR="/home/ec2-user/.ssh"
mkdir -p $USER_SSH_DIR
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7G7Kh34bN6bjc4UhagAFfgcIU8DgXn1d7KEM5ikTKgkx1T/qB55sp6jGcSHtxbqm4I6Wu4TSDjul9jkxe4t6ThjZEBPeeqNoeSEzqaVhRXxM8cDyX9F+f+UtxPB/KNCTYy03rpLV6dsFqwdxrFPtZsWfokcQSqGlMhkz76iHwo26CtnK+EhKktot6JxudfmdQMEmoxur7RZQHcUBGcrLPiY15u2ZL1Qneil6S8yTWYgkOi9OLt8keX7Vg7w8fxqVY/s/vcqVJuZzRW6cTo88Ekp5brWVpmtKdztlr+zdJ65jEfV06Q6jZHGKjwfcU0AcZmFbBsc0EUs/r9wkfjPG9 testppkkey" >> $USER_SSH_DIR/authorized_keys
chmod 700 $USER_SSH_DIR
chmod 600 $USER_SSH_DIR/authorized_keys
chown -R ec2-user:ec2-user $USER_SSH_DIR