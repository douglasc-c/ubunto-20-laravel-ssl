#!/bin/bash

# Define as cores para a saída do terminal
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
reset=`tput sgr0`

# Mensagem inicial
echo "${yellow}Starting...${reset}"
echo ""

# Instalando APACHE
echo "${green}[1/9] Installing APACHE${reset}"
sudo apt-get update
sudo apt-get install apache2 -y 
echo ""

# Instalando PHP
echo "${green}[2/9] Installing PHP${reset}"
echo "${yellow}[QUESTION] Type the version of PHP that you want to install:${reset}"
read phpVersion
sudo add-apt-repository ppa:ondrej/php -y 
sudo apt-get update 
sudo apt-get install -y php$phpVersion php$phpVersion-imap php$phpVersion-curl php$phpVersion-mysql php$phpVersion-mbstring php$phpVersion-bcmath php$phpVersion-simplexml php$phpVersion-imagick php$phpVersion-intl php$phpVersion-zip php$phpVersion-gd unzip curl openssl
sudo a2enmod rewrite
echo ""

# Instalando Composer
echo "${green}[3/9] Installing Composer${reset}"
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo service apache2 restart
echo ""

# Instalando Certbot para SSL
echo "${green}[4/9] Installing Certbot for SSL${reset}"
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update
sudo apt-get install certbot python3-certbot-apache -y
sudo certbot --apache
echo ""

# Gerando chave SSH
echo "${green}[5/9] Generating SSH Key${reset}"
sudo ssh-keygen
cat ~/.ssh/id_rsa.pub
echo "${blue}[ACTION] Copy the Key and Add in project at Github${reset}"
echo "${yellow}[QUESTION] Type 'YES' if you did that:${reset}"
read answer
sudo rm -rf /var/www/*
echo ""

# Clonando o repositório
echo "${green}[6/9] Cloning the repository${reset}"
echo "${yellow}[QUESTION] Type the repository:${reset}"
read gitRepository
cd /var/www
sudo git init  
sudo git remote add origin $gitRepository
sudo git pull origin master 
echo ""

# Instalação do Composer no projeto
echo "${green}[7/9] Project Composer install${reset}"
sudo composer install --ignore-platform-reqs
sudo chmod -R 777 bootstrap/cache
sudo chmod -R 777 /var/www/storage/logs
sudo chmod -R 777 storage
echo ""

# Atualizando os arquivos do Apache
echo "${green}[8/9] Update the files of Apache${reset}"
sudo curl -O https://raw.githubusercontent.com/luucasfzs/ubunto-20-laravel/master/files/virtualhost.txt
sudo mv virtualhost.txt /etc/apache2/sites-available/000-default.conf
sudo curl -O https://raw.githubusercontent.com/luucasfzs/ubunto-20-laravel/master/files/apache2.txt
sudo mv apache2.txt /etc/apache2/apache2.conf
sudo service apache2 restart
echo ""

# Instalando NODE
echo "${green}[9/9] Installing NODE${reset}" # Note que aqui você ultrapassou a contagem original de [8/8], então corrigi para [9/8]
echo "${yellow}[QUESTION] Type the version of NODE that you want to install:${reset}"
read nodeVersion
sudo curl -sL https://deb.nodesource.com/setup_$nodeVersion.x | sudo bash -
sudo apt -y install nodejs
sudo npm install
sudo npm run prod
echo ""

# Mensagem final
echo "${green}Finish${reset}"
