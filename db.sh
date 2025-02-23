#!/bin/bash
set -e

# This script installs MySQL Community Server on Amazon Linux 2.
# It first removes any outdated MySQL GPG key and imports the correct key,
# installs the EL7 MySQL repository package, creates necessary symlinks
# for OpenSSL libraries, and configures MySQL.

# Variables (override via environment if desired)
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-'YourNewRootPassword!'}
MYSQL_DATABASE=${MYSQL_DATABASE:-mydatabase}
MYSQL_USER=${MYSQL_USER:-user}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-userpassword}

echo "Updating system..."
sudo yum update -y

# Remove the old MySQL GPG key file if it exists.
if [ -f /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql ]; then
    echo "Removing outdated MySQL GPG key..."
    sudo rm -f /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
fi

# Import the current MySQL GPG key (released in 2022)
echo "Importing MySQL GPG key..."
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022

# Clean yum cache to avoid old metadata
sudo yum clean all

# Install the MySQL repository package for EL7 (make sure to use the correct URL)
echo "Installing MySQL repository package..."
sudo yum install -y https://repo.mysql.com/mysql80-community-release-el7-3.noarch.rpm

# Install MySQL Community Server
echo "Installing MySQL Community Server..."
sudo yum install -y mysql-community-server

# Create symlinks for OpenSSL libraries if they don't exist.
if [ ! -f /usr/lib64/libcrypto.so.10 ]; then
    if [ -f /usr/lib64/libcrypto.so.1.0.2k ]; then
        echo "Creating symlink for libcrypto.so.10..."
        sudo ln -s /usr/lib64/libcrypto.so.1.0.2k /usr/lib64/libcrypto.so.10
    else
        echo "Error: /usr/lib64/libcrypto.so.1.0.2k not found. Please ensure openssl-libs is installed."
        exit 1
    fi
fi

if [ ! -f /usr/lib64/libssl.so.10 ]; then
    if [ -f /usr/lib64/libssl.so.1.0.2k ]; then
        echo "Creating symlink for libssl.so.10..."
        sudo ln -s /usr/lib64/libssl.so.1.0.2k /usr/lib64/libssl.so.10
    else
        echo "Error: /usr/lib64/libssl.so.1.0.2k not found. Please ensure openssl-libs is installed."
        exit 1
    fi
fi

# Enable and start the MySQL service
echo "Enabling and starting MySQL service..."
sudo systemctl enable mysqld
sudo systemctl start mysqld

echo "Waiting for MySQL to initialize..."
sleep 15

# Retrieve the temporary password generated during installation
TEMP_PASSWORD=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}' | tail -n 1)
if [ -z "$TEMP_PASSWORD" ]; then
    echo "Error: Could not retrieve temporary MySQL root password."
    exit 1
fi
echo "Temporary MySQL root password: $TEMP_PASSWORD"

echo "Configuring MySQL database..."
mysql -uroot -p"$TEMP_PASSWORD" --connect-expired-password <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "MySQL installation and configuration complete."
