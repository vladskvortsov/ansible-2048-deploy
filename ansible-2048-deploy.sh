#/bin/bash

sudo apt-get update -y
sudo apt-get install -y ansible git

git clone https://github.com/vladskvortsov/ansible-2048-deploy.git

cd ansible-2048-deploy

sudo ansible-playbook playbook.yml -i /home/ubuntu/ansible-2048-deploy/hosts.ini -l controller -u root

#sudo scp -r -i /home/vlad/Завантаження/LightsailDefaultKey-eu-west-2.pem ubuntu@3.9.90.3:* /home/vlad/ansible-2048-deploy/

#curl https://ipinfo.io/ip

