#!/bin/bash
# Script para instalar, iniciar y configurar MySQL 8 en AWS EC2 con Amazon Linux 2 de forma no interactiva.
# Este script actualiza el sistema, instala MySQL (si es necesario), arranca y habilita el servicio,
# configura la seguridad (establece la contraseña root, elimina usuarios anónimos y la base de datos de prueba)
# y crea una base de datos y un usuario de prueba, todo sin interacción.

# Variables de configuración - Modifica estos valores según tus necesidades
NEW_ROOT_PASS="TuNuevaContraseñaSegura"   # Contraseña para el usuario root de MySQL
DB_NAME="basedatos_prueba"                 # Nombre de la base de datos de prueba
DB_USER="usuario_prueba"                   # Nombre del usuario de prueba
DB_USER_PASS="ContraseñaPrueba123"         # Contraseña para el usuario de prueba

# Función para imprimir mensajes informativos
function info() {
    echo -e "\n[INFO] $1\n"
}

# Función para buscar el archivo de unidad de MySQL en rutas comunes
function buscar_servicio() {
    if [ -f /usr/lib/systemd/system/mysqld.service ]; then
        echo "mysqld"
    elif [ -f /lib/systemd/system/mysqld.service ]; then
        echo "mysqld"
    elif [ -f /etc/systemd/system/mysqld.service ]; then
        echo "mysqld"
    elif [ -f /usr/lib/systemd/system/mysql.service ]; then
        echo "mysql"
    elif [ -f /lib/systemd/system/mysql.service ]; then
        echo "mysql"
    elif [ -f /etc/systemd/system/mysql.service ]; then
        echo "mysql"
    else
        echo ""
    fi
}

# Verificar que se esté ejecutando como root
if [[ "$EUID" -ne 0 ]]; then
    info "Este script debe ejecutarse como root o utilizando sudo."
    exit 1
fi

# 1. Verificar si el paquete mysql-community-server está instalado
if rpm -q mysql-community-server &> /dev/null; then
    info "MySQL Community Server ya está instalado en el sistema."
else
    info "Actualizando paquetes del sistema..."
    yum update -y
    amazon-linux-extras install epel -y

    # 2. Importar la clave GPG correcta para MySQL
    info "Importando la clave GPG..."
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

    # 3. Descargar e instalar el repositorio de MySQL
    info "Descargando el repositorio de MySQL..."
    wget https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm -O /tmp/mysql80-community-release-el7-11.noarch.rpm

    info "Limpiando la caché de YUM..."
    yum clean packages

    info "Instalando el repositorio de MySQL..."
    rpm -ivh /tmp/mysql80-community-release-el7-11.noarch.rpm

    # 4. Instalar MySQL Community Server
    info "Instalando MySQL Community Server..."
    yum install mysql-community-server -y --skip-broken
fi

# 5. Buscar el archivo de unidad del servicio MySQL
service_unit=$(buscar_servicio)
if [ -z "$service_unit" ]; then
    info "No se encontró el archivo de unidad para MySQL. Revisa la instalación del paquete."
    exit 1
fi

# 6. Iniciar y habilitar el servicio MySQL
info "Iniciando el servicio $service_unit..."
systemctl start $service_unit
systemctl enable $service_unit

# Esperar unos segundos para asegurar que el servicio se inicie
sleep 5

if systemctl is-active --quiet $service_unit; then
    info "El servicio $service_unit se inició correctamente."
else
    info "Error: El servicio $service_unit no se inició correctamente."
    exit 1
fi

info "Estado del servicio MySQL ($service_unit):"
systemctl status $service_unit --no-pager

# 7. Configuración de seguridad no interactiva de MySQL
# Se busca si se generó una contraseña temporal en el log
TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log | tail -1 | awk '{print $NF}')

if [ -z "$TEMP_PASS" ]; then
    info "Estableciendo la contraseña root..."
    mysql -uroot <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${NEW_ROOT_PASS}';
EOF
else
    info "Contraseña temporal encontrada. Configurando el usuario root con la nueva contraseña..."
    mysql --connect-expired-password -uroot -p"${TEMP_PASS}" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${NEW_ROOT_PASS}';
EOF
fi

info "Eliminando usuarios anónimos y la base de datos de prueba..."
mysql -uroot -p"${NEW_ROOT_PASS}" <<EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF

# 8. Crear base de datos y usuario de prueba
info "Creando la base de datos '${DB_NAME}' y el usuario '${DB_USER}'..."
mysql -uroot -p"${NEW_ROOT_PASS}" <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

info "La instalación y configuración de MySQL se completó exitosamente."
info "Acceso root: usuario 'root' con contraseña '${NEW_ROOT_PASS}'"
info "Base de datos creada: '${DB_NAME}'"
info "Usuario de la base de datos: '${DB_USER}' con contraseña '${DB_USER_PASS}'"
