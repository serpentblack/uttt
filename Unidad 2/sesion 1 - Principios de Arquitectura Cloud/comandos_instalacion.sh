# Actualizar el sistema
sudo apt update
sudo apt upgrade -y

# Instalar Apache
sudo apt install apache2 -y

# Iniciar y habilitar el servicio Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Instalar AWS CLI
sudo apt install unzip -y
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

# Instalar stress
sudo apt install stress

# Verificar la instalación de AWS CLI
aws --version
