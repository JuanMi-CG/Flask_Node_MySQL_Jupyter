#!/bin/bash
# db.sh: Installs MariaDB (as a MySQL-compatible server), starts the service, and configures the database.

# Check if the 'mysql' client is available
if ! command -v mysql &>/dev/null; then
    echo "MySQL/MariaDB is not installed. Installing MariaDB..."
    sudo dnf install -y mariadb-server
fi

echo "Starting MariaDB service..."
# On Amazon Linux 2023, the service name is typically "mariadb"
sudo systemctl start mariadb || sudo systemctl restart mariadb

# Wait for the DB to fully start
sleep 15

# Database configuration variables
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-rootpassword}
MYSQL_DATABASE=${MYSQL_DATABASE:-mydatabase}
MYSQL_USER=${MYSQL_USER:-user}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-userpassword}

echo "Configuring the database..."
mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "Database configuration complete."
