#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Set up Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install requirements from requirements.txt
if [ -f "requirements.txt" ]; then
    echo "Installing requirements..."
    pip install -r requirements.txt
else
    echo "requirements.txt not found. Please add it to the directory."
    deactivate
    exit 1
fi

# Create a basic inventory file
echo "Generating inventory file..."
cat <<EOL > inventory
[local]
localhost ansible_connection=local
EOL

# Create ansible user if it does not exist
if ! id "ansible" &>/dev/null; then
    echo "Creating 'ansible' user..."
    useradd -m ansible
else
    echo "'ansible' user already exists."
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

# Deactivate virtual environment
deactivate

# Final instructions
echo "Setup complete. Please set a password for the 'ansible' user:"
passwd ansible

echo "Switch to the 'ansible' user by running:"
echo "su - ansible"
