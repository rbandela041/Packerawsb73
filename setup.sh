#!/bin/bash

# 1. Update the system & Install Nginx
sudo dnf update -y
sudo dnf install nginx -y

# 2. Enable Nginx
sudo systemctl enable nginx

# 3. Setup the Website Template
sudo mv /tmp/index.html /usr/share/nginx/html/index.template.html
sudo chmod 644 /usr/share/nginx/html/index.template.html
sudo chown root:root /usr/share/nginx/html/index.template.html

# --- NEW STEP: DOWNLOAD THE GIF LOCALLY ---
# We download the gif once during the build. Now it lives on the server forever.
sudo curl -L -o /usr/share/nginx/html/matrix.gif "https://upload.wikimedia.org/wikipedia/commons/c/c0/Matrix_digital_rain.gif"
sudo chmod 644 /usr/share/nginx/html/matrix.gif
sudo chown root:root /usr/share/nginx/html/matrix.gif
# ------------------------------------------

# 4. Create the "Smart Boot" Script
cat << 'EOF' | sudo tee /usr/local/bin/update_web.sh
#!/bin/bash

# Get the IMDSv2 Token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Fetch Public IP and FQDN
MY_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)
MY_DNS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-hostname)

if [ -z "$MY_DNS" ]; then
    MY_DNS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/hostname)
fi

# Update index.html from template
sed -e "s/{{PUBLIC_IP}}/$MY_IP/g" \
    -e "s/{{FQDN}}/$MY_DNS/g" \
    /usr/share/nginx/html/index.template.html > /usr/share/nginx/html/index.html
EOF

# 5. Make the boot script executable and run it
sudo chmod +x /usr/local/bin/update_web.sh
sudo /usr/local/bin/update_web.sh

# 6. Ensure it runs on reboot
echo "/usr/local/bin/update_web.sh" | sudo tee -a /etc/rc.d/rc.local
sudo chmod +x /etc/rc.d/rc.local

# 7. Add SSH Key
USER_SSH_DIR="/home/ec2-user/.ssh"
mkdir -p $USER_SSH_DIR
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7G7Kh34bN6bjc4UhagAFfgcIU8DgXn1d7KEM5ikTKgkx1T/qB55sp6jGcSHtxbqm4I6Wu4TSDjul9jkxe4t6ThjZEBPeeqNoeSEzqaVhRXxM8cDyX9F+f+UtxPB/KNCTYy03rpLV6dsFqwdxrFPtZsWfokcQSqGlMhkz76iHwo26CtnK+EhKktot6JxudfmdQMEmoxur7RZQHcUBGcrLPiY15u2ZL1Qneil6S8yTWYgkOi9OLt8keX7Vg7w8fxqVY/s/vcqVJuZzRW6cTo88Ekp5brWVpmtKdztlr+zdJ65jEfV06Q6jZHGKjwfcU0AcZmFbBsc0EUs/r9wkfjPG9 testppkkey" >> $USER_SSH_DIR/authorized_keys
chmod 700 $USER_SSH_DIR
chmod 600 $USER_SSH_DIR/authorized_keys
chown -R ec2-user:ec2-user $USER_SSH_DIR