#!/bin/bash

# Install yum-utils
dnf -y install yum-utils yum tar

# Add the MS repo
curl https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo

# Add the hashicorp repo
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Add gh cli repo
yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

# Add the kubernetes repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Add azure-cli repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/azure-cli.repo

# Add jfrog-cli repo
echo "[jfrog-cli]" > /etc/yum.repos.d/jfrog-cli.repo
echo "name=jfrog-cli" >> /etc/yum.repos.d/jfrog-cli.repo
echo "baseurl=https://releases.jfrog.io/artifactory/jfrog-rpms" >> /etc/yum.repos.d/jfrog-cli.repo
echo "enabled=1" >> /etc/yum.repos.d/jfrog-cli.repo
rpm --import https://releases.jfrog.io/artifactory/jfrog-gpg-public/jfrog_public_gpg.key

# Upgrade the image
dnf -y upgrade

# Install all the needed tools
dnf -y install jfrog-cli-v2-jf net-tools bind-utils go wget sudo unzip python3.9 azure-cli openssl git vim iputils procps-ng powershell terraform kubectl jq lttng-ust openssl-libs openssl-pkcs11 krb5-libs zlib libicu gh nodejs findutils ruby go nginx

# Install jwt
gem install jwt

# Install packer
version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r .current_version)
curl -LO "https://releases.hashicorp.com/packer/${version}/packer_${version}_linux_amd64.zip"
unzip -qq "packer_${version}_linux_amd64.zip" -d /usr/local/bin
rm -f "packer_${version}_linux_amd64.zip"

# Install Terragrunt
version=$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r .tag_name)
wget https://github.com/gruntwork-io/terragrunt/releases/download/${version}/terragrunt_linux_amd64 -O terragrunt
chmod +x terragrunt
mv terragrunt /usr/local/bin/

# Install HELM
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install sentinel
version=$(curl -sL https://releases.hashicorp.com/sentinel/index.json | jq -r '.versions[].version' | grep -v '[-].*' | sort -rV | head -n 1)
curl -s -o "sentinel_${version}_linux_amd64.zip" -L "https://releases.hashicorp.com/sentinel/${version}/sentinel_${version}_linux_amd64.zip"
unzip -qq "sentinel_${version}_linux_amd64.zip" -d /usr/local/bin
rm -f "sentinel_${version}_linux_amd64.zip"

# Install the aks-preview extension
az extension add --name aks-preview

# Install python packages
wget https://bootstrap.pypa.io/get-pip.py
python3.9 get-pip.py
python3.9 -m pip install --upgrade pip
python3.9 -m pip install virtualenv wheel
python3.9 -m pip install pywinrm ansible databricks-cli kubernetes terraform-compliance
ansible-galaxy collection install crowdstrike.falcon servicenow.itsm azure.azcollection kubernetes.core
pip3.9 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt

# Add user github
useradd -m github && echo "%github ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Edit the nginx config file
sed -i 's/user nginx;/# user nginx;/g' /etc/nginx/nginx.conf

# Set default HTTP port to 8080
sed -i 's/80/8080/g' /etc/nginx/nginx.conf

# Add permissions on the required directories
chown -R github:github /usr/share/nginx
chown -R github:github /var/lib/nginx
chown -R github:github /var/log/nginx
chown -R github:github /run

# Remove yum cache
dnf -y clean all

# Install the PowerShell Az module
pwsh -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Install-Module -Name Az -Scope AllUsers -Force -Verbose"
