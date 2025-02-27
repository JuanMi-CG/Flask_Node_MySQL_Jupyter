#!/bin/bash
#-----------------------------------------------
# Configuración de reserva de memoria para ECS y límite de zram
#-----------------------------------------------

# Reservar 256 MB para procesos críticos (para el agente ECS u otros servicios vitales)
sudo mkdir -p /etc/ecs
echo "ECS_RESERVED_MEMORY=256" | sudo tee /etc/ecs/ecs.config

# Configurar zram para limitar su uso a 800MB
sudo mkdir -p /etc/systemd/zram-generator.conf.d
echo "[zram0]" | sudo tee /etc/systemd/zram-generator.conf.d/limit.conf
echo "max_size = 800M" | sudo tee -a /etc/systemd/zram-generator.conf.d/limit.conf

#-----------------------------------------------
# Actualizar el sistema e instalar Git
#-----------------------------------------------
sudo yum update -y
sudo yum install -y git

#-----------------------------------------------
# Crear el directorio del proyecto y clonar el repositorio
#-----------------------------------------------
mkdir -p /home/ec2-user/ERP
cd /home/ec2-user/ERP
git clone https://github.com/JuanMi-CG/Flask_Node_MySQL_Jupyter .

# Cambiar el propietario de la carpeta al usuario ec2-user
sudo chown -R ec2-user:ec2-user /home/ec2-user/ERP

# Dar permisos de ejecución al script de inicialización y ejecutarlo
cd /home/ec2-user/ERP
chmod +x *.sh
# sudo ./init.sh
