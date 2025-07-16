#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

yum update -y
yum install -y git

sudo -u ec2-user -i <<'EOF'
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="/home/ec2-user/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 16

git clone https://github.com/azure-samples/nodejs-docs-hello-world.git /home/ec2-user/app
cd /home/ec2-user/app
npm install
PORT=3000 node index.js &
EOF
