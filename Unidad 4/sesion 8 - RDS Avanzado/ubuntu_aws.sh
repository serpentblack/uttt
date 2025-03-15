#!/bin/bash
# Actualizar los paquetes
sudo apt-get update -y
sudo apt-get upgrade -y

# Instalar unzip
sudo apt install unzip	

#instalacion aws cli
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
