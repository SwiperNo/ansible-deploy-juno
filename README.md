# ansible-deploy-juno
Ansible playbooks to deploy the Juno container and update it. This will install on the localhost as is.
# Juno Deployment with Ansible

This repository provides an Ansible-based setup for deploying and updating the Juno container, a Starknet full-node client implemented in Go.

## Setup

1. **Run the Setup Script**

   The setup script will:
   - Create a Python virtual environment.
   - Install required dependencies from `requirements.txt`.
   - Generate an inventory file with localhost configuration.
   - Create an `ansible` user with passwordless sudo permissions for Ansible tasks.

   Run the setup script as root:

   ```bash
   sudo ./setup_env.sh
