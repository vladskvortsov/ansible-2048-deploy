#/bin/bash

sudo apt-get update -y
sudo apt-get install -y ansible


echo '
[servers]

controller ansible_host=localhost

[all:vars]
ansible_python_interpreter=/usr/bin/python3     
' > /etc/home/ubuntu/hosts.ini

sudo ansible-playbook playbook.yml -i /home/ubuntu/hosts.ini -l controller -u root
