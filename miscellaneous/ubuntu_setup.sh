sudo apt update
sudo apt upgrade

#essential packages
echo "\nInstalling essential package...\n"
sudo apt install -y git curl net-tools openssh-client openssh-server ca-certificates

#brave
echo "\nInstalling Brave...\n"
curl -fsS https://dl.brave.com/install.sh | sh

#spotify
echo -e "\nInstalling Spotify...\n"
curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client

#wireshark
echo -e "\nInstalling wireshark...\n"
sudo apt install wireshark
sudo usermod -aG wireshark "$USER"

#docker
echo -e "\nInstalling Docker for non root user...\n"
sudo apt-get update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
docker run hello-world

# gcc
echo -e "\nInstalling gcc...\n"
sudo apt install -y gcc

#nodejs
echo -e "\nInstalling nodejs...\n"
sudo apt install -y nodejs

# npm
echo -e "\nInstalling npm...\n"
sudo apt install -y npm

#ssh
echo -e "\nStarting sshd...\n"
sudo systemctl start sshd
sudo systemctl enable sshd

#vlc
echo -e "\nInstalling vlc...\n"
sudo apt-get install -y vlc

##ufw
#echo -e "\nInstalling ufw for ssh...\n"
#sudo apt install -y ufw
#sudo ufw enable
#sudo ufw allow ssh
#sudo ufw allow 22

#neofetch
echo -e "\nInstalling neofetch...\n"
sudo apt-get install -y neofetch

#postman
#snap install postman

#slack
#sudo snap install slack