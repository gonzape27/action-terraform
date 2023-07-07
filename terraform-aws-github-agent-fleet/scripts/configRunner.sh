#!/bin/bash
cat <<EOF >/home/ubuntu/user-data.sh
#!/bin/bash
###Update and upgrade
echo "Update and upgrade base OS"
DEBIAN_FRONTEND=noninteractive 
sudo DEBIAN_FRONTEND=noninteractive apt-get update && apt upgrade  -y
#########
###Ansible
echo "Installing Ansible and dependencies"
sudo DEBIAN_FRONTEND=noninteractive  apt-get install python3 python3-pip  python-is-python3 ansible jq unzip  -y
pip3 install botocore boto3
ansible-galaxy collection install amazon.aws
#########
###Terraform
echo "Installing Terraform and dependencies"
sudo DEBIAN_FRONTEND=noninteractive apt install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo DEBIAN_FRONTEND=noninteractive apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" -y
sudo DEBIAN_FRONTEND=noninteractive apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install terraform -y
###DOCKER
sudo DEBIAN_FRONTEND=noninteractive apt-get install  curl apt-transport-https ca-certificates software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y ;
sudo DEBIAN_FRONTEND=noninteractive apt update -y;
sudo DEBIAN_FRONTEND=noninteractive apt install docker-ce -y;
sudo DEBIAN_FRONTEND=noninteractive systemctl enable docker;
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
mkdir .docker
echo '{
        "auths": {
                "https://index.docker.io/v1/": {
                        "auth": "Z2l0aHVib2tlcmE6anhkLWpkeSpkenI1Y2R1IUhWUA=="
                }
        }
}' >.docker/config.json
#########
###AWS
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
#########
###GithubRunner
echo "Installing GithubRunner and dependencies"
mkdir ~/actions-runner
cd ~/actions-runner
curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.299.1/actions-runner-linux-x64-2.299.1.tar.gz
tar -xzf ~/actions-runner/actions-runner.tar.gz
rm ~/actions-runner/actions-runner.tar.gz
ACTION_TOKEN=$(echo '$(aws secretsmanager get-secret-value --secret-id "GitHub/iac/token" | jq --raw-output '.SecretString' | jq -r .GITHUB_ACTION_GITHUBTOKEN)')
RUNNER_TOKEN=$(echo '$(curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ACTION_TOKEN" https://api.github.com/enterprises/okera/actions/runners/registration-token | jq -r '.token')')
~/actions-runner/config.sh --url https://github.com/enterprises/okera --token \$RUNNER_TOKEN --unattended
sudo ~/actions-runner/svc.sh install 
sudo systemctl restart actions.runner.enterprises-okera.$HOSTNAME.service
sudo systemctl enable actions.runner.enterprises-okera.$HOSTNAME.service
sudo systemctl status actions.runner.enterprises-okera.$HOSTNAME.service
rm /home/ubuntu/user-data.sh
#########
EOF
cd /home/ubuntu
chmod +x user-data.sh
/bin/su -c "./user-data.sh" - ubuntu | tee /home/ubuntu/user-data.log
