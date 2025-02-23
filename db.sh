#!/bin/bash
# db.sh: Installs MySQL Server on Amazon Linux 2023, starts the service, and configures the database.

# Check if the mysql client is available.
if ! command -v mysql &>/dev/null; then
    echo "MySQL is not installed. Installing MySQL Server..."
    # Download and install the MySQL repository RPM.
    sudo dnf install -y https://repo.mysql.com/mysql80-community-release-el8-1.noarch.rpm
    # Now install MySQL Community Server.
    sudo dnf install -y mysql-community-server
fi

echo "Starting MySQL service..."
# Start (or restart) the MySQL service. The service is typically named 'mysqld'.
sudo systemctl start mysqld || sudo systemctl restart mysqld

# Wait a bit for MySQL to fully start.
sleep 15

# Database configuration variables (defaults can be overridden by environment variables).
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
