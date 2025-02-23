#!/bin/bash
# db.sh: Instala MySQL (si no está instalado), inicia el servicio y configura la base de datos.

# Verificar si MySQL está instalado
if ! command -v mysql &>/dev/null; then
    echo "MySQL no está instalado. Instalando MySQL..."
    sudo amazon-linux-extras enable mysql8.0
    sudo yum clean metadata
    sudo yum install -y mysql-community-server
fi

echo "Iniciando MySQL..."
# Iniciar MySQL (usar systemctl o service según la versión de Amazon Linux)
if command -v systemctl &>/dev/null; then
    sudo systemctl start mysqld || sudo systemctl restart mysqld
else
    sudo service mysqld start
fi

# Esperar para que MySQL inicie
sleep 15

# Variables de configuración (pueden ser sobrescritas externamente)
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-rootpassword}
MYSQL_DATABASE=${MYSQL_DATABASE:-mydatabase}
MYSQL_USER=${MYSQL_USER:-user}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-userpassword}

echo "Configurando la base de datos..."
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "La base de datos ha sido configurada."
