#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Create ansible user if it does not exist
if ! id "ansible" &>/dev/null; then
    echo "Creating 'ansible' user..."
    useradd -m ansible
    echo "Please set a password for the 'ansible' user:"
    passwd ansible
fi

# Add ansible user to sudo or wheel group
if grep -qEi "(debian|ubuntu)" /etc/os-release; then
    echo "Adding 'ansible' user to sudo group..."
    usermod -aG sudo ansible
else
    echo "Adding 'ansible' user to wheel group..."
    usermod -aG wheel ansible
fi


# Configure passwordless sudo for ansible user
echo "Configuring passwordless sudo for 'ansible' user..."
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

# Switch to ansible user’s home directory
echo "Switcing to ansible user home directory..."
cd /home/ansible || exit 1

# Copy cloned repo to the ansible home directory
echo "Copying deployment setup to ansible user home directory..."
cp -r ansible-deploy-juno/* /home/ansible/


# Install Docker
if grep -qEi "(debian|ubuntu)" /etc/os-release; then
    echo "Installing Docker for Ubuntu..."
    apt update -y
    apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt update
    apt install -y docker-ce
elif grep -qEi "(centos|fedora|rhel)" /etc/os-release; then
    echo "Installing Docker for Red Hat-based systems..."
    dnf update -y
    dnf install -y yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    dnf install -y docker-ce docker-ce-cli containerd.io
    systemctl start docker
    systemctl enable docker
else
    echo "Unsupported OS. Exiting."
    exit 1
fi

# Add ansible user to Docker group
echo "Adding ansible user to docker group and refreshing group..."
sudo usermod -aG docker ansible
# Refresh and add ansible user to group
sudo newgrp docker


# Set up Python virtual environment
echo "Creating Python virtual environment..."
su - ansible -c "python3 -m venv ~/venv && source ~/venv/bin/activate"

# Install requirements from requirements.txt
if [ -f "/home/ansible/requirements.txt" ]; then
    echo "Installing requirements..."
    su - ansible -c "source ~/venv/bin/activate && pip install -r ~/requirements.txt"
else
    echo "requirements.txt not found. Please add it to the ansible user's home directory."
    exit 1
fi

# Create a basic inventory file
echo "Generating inventory file..."
cat <<EOL > /home/ansible/inventory
[local]
localhost ansible_connection=local
EOL

# Updating ownsership of all files
echo "Updating ansible user ownership for files..."
chown ansible:ansible /home/ansible/*

# Validate Docker installation
echo "Validating Docker installation..."
su - ansible -c "docker run hello-world"

echo "Setup complete. Switch to the 'ansible' user by running:"
echo "su - ansible"
echo "Activate the Python virtual environment with:"
echo "source ~/venv/bin/activate"
