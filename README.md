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
   ```

   Follow the on-screen instructions to set a password for the `ansible` user and switch to the `ansible` user:

   ```bash
   su - ansible
   ```

2. **Activate the Virtual Environment**

   Once logged in as the `ansible` user, activate the virtual environment:

   ```bash
   source venv/bin/activate
   ```

## Deployment

To deploy the Juno container, run the following playbook:

```bash
ansible-playbook -i inventory deploy-juno.yaml
```

This playbook will:
- Pull the Juno Docker image.
- Deploy the Juno container with the specified configuration file.
- Validate that the container is running and check logs for expected output.

## Updating Juno

To update the Juno container to the latest version, use the `update-juno.yaml` playbook:

```bash
ansible-playbook -i inventory update-juno.yaml
```

This playbook will:
- Stop and remove the current Juno container (if running).
- Pull the latest Juno Docker image.
- Redeploy the Juno container with the latest version.
- Validate the deployment by checking container logs.

## Notes

- Ensure the `requirements.txt` file includes the necessary dependencies for Ansible and Docker modules.
- Modify the `juno_vars.yml` file as needed for custom configurations.
- Run the playbooks as the `ansible` user after switching to the virtual environment.

## Troubleshooting

- If there are issues with the setup script, verify that the `venv` directory is created correctly and that dependencies in `requirements.txt` are properly installed.
- Ensure Docker is installed and running on the localhost where these playbooks are executed.

---

This repository enables easy setup, deployment, and updating of the Juno container with Ansible, providing a repeatable and automated approach for Starknet node management.
