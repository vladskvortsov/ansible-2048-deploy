#/bin/bash

sudo apt-get update -y
sudo apt-get install -y ansible git

git clone https://github.com/vladskvortsov/ansible-2048-deploy.git

cd ansible-2048-deploy

sudo ansible-playbook playbook.yml -i /home/ubuntu/ansible-2048-deploy/hosts.ini -l controller -u ubuntu

#sudo scp -r -i /home/vlad/Завантаження/LightsailDefaultKey-eu-west-2.pem ubuntu@3.9.90.3:* /home/vlad/ansible-2048-deploy/

#curl https://ipinfo.io/ip

#cat ~/.ssh/id_rsa.pub




#apk --update add certbot certbot-nginx nano curl
#certbot --nginx -d oldgood2048.ga -d www.oldgood2048.ga
#certbot renew --dry-run
#nginx -s reload

