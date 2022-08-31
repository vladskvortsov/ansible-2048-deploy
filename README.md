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
---
- hosts: all
  become: true
  vars:
    created_username: ansible
  tasks:
    - name: Setup passwordless sudo
      lineinfile:
        path: /etc/sudoers
        state: present
        regexp: '^%sudo'
        line: '%sudo ALL=(ALL) NOPASSWD: ALL'
        validate: '/usr/sbin/visudo -cf %s' 

    - name: Create a new regular user with sudo privileges
      user:
        name: "{{ created_username }}"
        state: present
        groups: sudo
        append: true
        create_home: true

    - name: Set authorized key for remote user
      ansible.posix.authorized_key:
        user: "{{ created_username }}"
        state: present
        key: "{{ lookup('file', lookup('env','HOME') + '/.ssh/id_rsa.pub') }}"

    - name: Disable password authentication for root
      lineinfile:
        path: /etc/ssh/sshd_config
        state: present
        regexp: '^#?PermitRootLogin'
        line: 'PermitRootLogin prohibit-password'

    - name: UFW - Allow SSH connections
      community.general.ufw:
        rule: allow
        name: OpenSSH

    - name: UFW - Enable and deny by default
      community.general.ufw:
        state: enabled
        default: deny

    - name: Install aptitude
      apt:
        name: aptitude
        state: latest
        update_cache: true

    - name: Install required system packages
      apt:
        pkg:
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
          - python3-pip
          - virtualenv
          - python3-setuptools
        state: latest
        update_cache: true

    - name: Add Docker GPG apt Key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker Repository
      apt_repository:
        repo: deb https://download.docker.com/linux/ubuntu focal stable
        state: present

    - name: Update apt and install docker-ce
      apt:
        name: docker-ce
        state: latest
        update_cache: true

    - name: Install Docker Module for Python
      pip:
        name: docker

    - name: Deploy docker-2048 container
      docker_container:
        image: vladskvortsov/docker-2048:latest
        name: docker-2048
        state: started
        auto_remove: true
        ports:
          - "8080:80"
``` 
