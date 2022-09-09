# Ansible Playbook for deploying docker version of 2048

This Playbook deploys preconfigured docker image with webserver inside and setup domain name for it. As example i use [docker-2048][git-2048] image.

### Prerequisites

- Ansible controller node
- One or more Ansible hosts. User with sudo priveleges is required
- Setuped SSH connection from controller to the host
- Purchased or free domain name (`Adding server ip address to the domain properities is required`)

### What this Playbook do:

-- Setup passwordless sudo

-- Create a new user with sudo privileges

-- Sets authorized key for new user

-- Disable password authentication for root

-- Setup firewall for ssh conections

-- Install addition packages

-- Install Docker

-- Deploy light docker 2048 image based on alpine linux

-- Add domain name to the target server config

#### Top level files:

**playbook.yml**

Main playbook file, contains only links to playbooks for specific groups of servers (webservers, database servers etc.), in my case `webserver.yml`.

```s
#main playbook
---
- import_playbook: webserver.yml
```

**webserver.yml**

Contains configuration for webservers: list of target machines, roles and other.

```sh
---
- hosts: all
  connection: local
  become: true
  roles:
   - add-user-and-ssh-key
   - docker-install
   - docker-2048-deploy
   - add-domain-name
```
> Note: `connection: local` required only if target is local ansible controller  machine, otherwise it should replaced.

**hosts.ini**

Reqired to store list of `all` target servers. In my case localhost only.
```sh
[servers]
controller ansible_host=localhost
[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### Tasks:

**add-user-and-ssh-key**

```sh
---
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
        shell: /bin/bash
        append: true
        create_home: true

    - name: Set authorized key for remote user
      authorized_key:
       user: "{{ created_username }}"
       state: present
       key: "{{ ssh_pub_key }}"

#    - name: Set authorized key took from file
#      authorized_key:
#        user: "{{ created_username }}"
#        state: present
#        key: "{{ lookup('file', '~/ansible-2048-deploy/id_rsa.pub') }}"

    - name: Disable password authentication for root
      lineinfile:
        path: /etc/ssh/sshd_config
        state: present
        regexp: '^#?#PermitRootLogin yes'
        line: ' PermitRootLogin prohibit-password'


#    - name: Allow all access to tcp port 80
#      ufw:
#        rule: allow
#        port: '80'
#        proto: tcp

    - name: UFW - Enable and deny by default
      ufw:
        state: enabled
        default: deny
      notify:
        - UFW start service

    - name: UFW - Allow SSH connections
      ufw:
        rule: allow
        name: OpenSSH
      notify:
        - SSH restart service

```

**docker-install**

```sh
---
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
```

**docker-2048-deploy**

```sh
---    
- name: Deploy docker-2048 container
  docker_container:
    image: vladskvortsov/docker-2048:latest
    name: docker-2048
    state: started
    auto_remove: true
    ports:
      - "80:80"
#     - "443:443"
```

**add-domain-name**

```sh
---
   - name: Add-domain-name
     lineinfile:
        path: /etc/hosts
        state: present
        regexp: '^#?127.0.0.1 localhost;'
        line: '127.0.0.1 localhost {{ domain_name }} www.{{ domain_name }};'

   - name: Add-domain-name-ip6
     lineinfile:
        path: /etc/hosts
        state: present
        regexp: '^#?::1 ip6-localhost ip6-loopback'
        line: '::1 ip6-localhost ip6-loopback ip6-{{ domain_name }} ip6-www.{{ domain_name }}'
```

### Variables

**created_username**

Put here [roles/add-user-and-ssh-key/vars/main.yml][user-var] name of sudo user you wish to add.

**ssh_pub_key**

Put here [roles/add-user-and-ssh-key/vars/main.yml][user-var] content of ssh
public key from your local machine. If you not already have one, you may generate key pair using:

```sh
ssh-keygen
```

 To show the content of your public key run:

```sh
cat ~/.ssh/id_rsa.pub
```

**domain_name**

Put here [roles/add-domain-name/vars/main.yml][domain-var] your hosted domain name.



To run playbook clone this repository:

```sh
 git clone https://github.com/vladskvortsov/ansible-2048-deploy.git
 cd ansible-2048-deploy
```

and run it specifying path to hosts.ini, target host `controller`, and user `ubuntu`(should be replaced within yours ofcource):

```sh
sudo ansible-playbook playbook.yml -i /home/ubuntu/ansible-2048-deploy/hosts.ini -l controller -u ubuntu
```


When ansible ends, be free to access your image content from browser, using your domain name.

[git-2048]: <https://github.com/vladskvortsov/docker-2048.git>
[user-var]:<https://github.com/vladskvortsov/ansible-2048-deploy/blob/master/roles/add-user-and-ssh-key/vars/main.yml>
[domain-var]: <https://github.com/vladskvortsov/ansible-2048-deploy/blob/master/roles/add-domain-name/vars/main.yml>
