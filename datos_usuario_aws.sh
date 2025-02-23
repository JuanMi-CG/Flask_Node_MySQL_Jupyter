#!/bin/bash
# Actualizar el sistema
sudo yum update -y

# Instalar Git
sudo yum install -y git

# Crear el directorio del proyecto y clonar el repositorio
mkdir -p /home/ec2-user/ERP
cd /home/ec2-user/ERP
git clone https://github.com/JuanMi-CG/Flask_Node_MySQL_Jupyter .

# Cambiar el propietario de la carpeta al usuario ec2-user
sudo chown -R ec2-user:ec2-user /home/ec2-user/ERP

# Dar permisos de ejecución al script de inicialización y ejecutarlo
cd /home/ec2-user/ERP
chmod +x init.sh
./init.sh
