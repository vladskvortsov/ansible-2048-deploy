# Ansible Playbook for deploying Docker version of 2048

### Prerequisites

- Ansible controller node
- One or more Ansible hosts (user with sudo priveleges is required)
- Setuped SSH connection from controller to the host


### What this Playbook do:

-- Setups passwordless sudo

-- Creates a new user with sudo privileges

-- Sets authorized key for new user

-- Disableing password authentication for root

-- Setups firewall for ssh connections

-- Installs addition packages

-- Installs Docker

-- Deploys light docker 2048 image based on alpine linux


### Playbook:

```sh


``` 
