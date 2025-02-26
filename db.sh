#!/bin/bash
# Script para instalar, reiniciar y configurar MySQL 8 en AWS EC2 con Amazon Linux 2 de forma no interactiva.
# Se asegura que la base de datos tenga siempre los parámetros predefinidos, sin importar si es la primera
# ejecución o no. Además, si el servicio ya estaba activo, se reinicia.
# Se actualiza la contraseña de root (usando --connect-expired-password para evitar el ERROR 1820)
# y se configura la política de contraseñas, se eliminan usuarios anónimos y la base de datos de prueba,
# y se crea la base de datos y el usuario remoto con todos los permisos.

# Variables de configuración - Modifica estos valores según tus necesidades
NEW_ROOT_PASS="Administrador123!"           # Contraseña para el usuario root de MySQL
DB_NAME="ERP"                              # Nombre de la base de datos que se creará (opcional)
DB_USER="remoto"                           # Nombre del usuario remoto
DB_USER_PASS="Remoto123!"                  # Contraseña para el usuario remoto

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

    # Importar la clave GPG de MySQL
    info "Importando la clave GPG..."
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

    # Descargar e instalar el repositorio de MySQL
    info "Descargando el repositorio de MySQL..."
    wget https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm -O /tmp/mysql80-community-release-el7-11.noarch.rpm

    info "Limpiando la caché de YUM..."
    yum clean packages

    info "Instalando el repositorio de MySQL..."
    rpm -ivh /tmp/mysql80-community-release-el7-11.noarch.rpm

    # Instalar MySQL Community Server
    info "Instalando MySQL Community Server..."
    yum install mysql-community-server -y --skip-broken
fi

# 2. Buscar el archivo de unidad del servicio MySQL
service_unit=$(buscar_servicio)
if [ -z "$service_unit" ]; then
    info "No se encontró el archivo de unidad para MySQL. Revisa la instalación del paquete."
    exit 1
fi

# 3. Reiniciar el servicio si ya estaba activo, o iniciarlo si no lo estaba
if systemctl is-active --quiet $service_unit; then
    info "El servicio $service_unit ya está activo. Reiniciándolo..."
    systemctl restart $service_unit
else
    info "Iniciando el servicio $service_unit..."
    systemctl start $service_unit
    systemctl enable $service_unit
fi

# Esperar unos segundos para que el servicio se estabilice
sleep 5

if systemctl is-active --quiet $service_unit; then
    info "El servicio $service_unit está activo."
else
    info "Error: El servicio $service_unit no se inició/reinició correctamente."
    exit 1
fi

info "Estado del servicio MySQL ($service_unit):"
systemctl status $service_unit --no-pager

# 4. Actualización de la contraseña de root y ajuste de la política de contraseñas
# Se revisa si hay una contraseña temporal en el log (se genera en la primera ejecución)
TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log | tail -1 | awk '{print $NF}')
if [ -n "$TEMP_PASS" ]; then
    info "Contraseña temporal encontrada: $TEMP_PASS. Actualizando contraseña de root..."
    CURRENT_PASS="$TEMP_PASS"
else
    info "No se encontró contraseña temporal. Se utilizará la contraseña predefinida para root."
    CURRENT_PASS="$NEW_ROOT_PASS"
fi

# Conectar usando --connect-expired-password y ejecutar solo ALTER USER como primer comando
mysql --connect-expired-password -uroot -p"${CURRENT_PASS}" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${NEW_ROOT_PASS}';"
if [ $? -ne 0 ]; then
     info "Error al actualizar la contraseña de root."
     exit 1
fi

# Ajustar la política de contraseñas a nivel GLOBAL
mysql -uroot -p"${NEW_ROOT_PASS}" <<EOF
SET GLOBAL validate_password.policy=LOW;
SET GLOBAL validate_password.length=4;
EOF

if [ $? -ne 0 ]; then
     info "Error al configurar la política de contraseñas."
     exit 1
fi

# 5. Eliminar usuarios anónimos y la base de datos de prueba
info "Eliminando usuarios anónimos y la base de datos de prueba..."
mysql -uroot -p"${NEW_ROOT_PASS}" <<EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
FLUSH PRIVILEGES;
EOF

if [ $? -ne 0 ]; then
    info "Error al eliminar usuarios anónimos o la base de datos de prueba."
    exit 1
fi

# 6. Crear la base de datos y el usuario remoto con todos los permisos
info "Creando la base de datos '${DB_NAME}' y el usuario remoto '${DB_USER}'..."
mysql -uroot -p"${NEW_ROOT_PASS}" <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

if [ $? -ne 0 ]; then
    info "Error al crear la base de datos o el usuario remoto."
    exit 1
fi

info "La instalación y configuración de MySQL se completó exitosamente."
info "Acceso root: usuario 'root' con contraseña '${NEW_ROOT_PASS}'"
info "Base de datos creada: '${DB_NAME}'"
info "Usuario remoto: '${DB_USER}' con contraseña '${DB_USER_PASS}'"
