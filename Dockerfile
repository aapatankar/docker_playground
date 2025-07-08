# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=myapp
ENV MYSQL_USER=appuser
ENV MYSQL_PASSWORD=apppassword

# Update package list and install required packages
RUN apt-get update && \
    apt-get install -y \
    mysql-server \
    mysql-client \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Create MySQL configuration directory and custom config
RUN mkdir -p /etc/mysql/conf.d && \
    echo "[mysqld]" > /etc/mysql/conf.d/custom.cnf && \
    echo "bind-address = 0.0.0.0" >> /etc/mysql/conf.d/custom.cnf && \
    echo "port = 3307" >> /etc/mysql/conf.d/custom.cnf && \
    echo "default-authentication-plugin = mysql_native_password" >> /etc/mysql/conf.d/custom.cnf && \
    echo "skip-host-cache" >> /etc/mysql/conf.d/custom.cnf && \
    echo "skip-name-resolve" >> /etc/mysql/conf.d/custom.cnf && \
    echo "datadir = /var/lib/mysql" >> /etc/mysql/conf.d/custom.cnf && \
    echo "socket = /var/run/mysqld/mysqld.sock" >> /etc/mysql/conf.d/custom.cnf && \
    echo "pid-file = /var/run/mysqld/mysqld.pid" >> /etc/mysql/conf.d/custom.cnf && \
    echo "log-error = /var/log/mysql/error.log" >> /etc/mysql/conf.d/custom.cnf && \
    echo "" >> /etc/mysql/conf.d/custom.cnf && \
    echo "[mysql]" >> /etc/mysql/conf.d/custom.cnf && \
    echo "default-character-set = utf8mb4" >> /etc/mysql/conf.d/custom.cnf && \
    echo "" >> /etc/mysql/conf.d/custom.cnf && \
    echo "[client]" >> /etc/mysql/conf.d/custom.cnf && \
    echo "default-character-set = utf8mb4" >> /etc/mysql/conf.d/custom.cnf

# Create necessary directories and set permissions
RUN mkdir -p /var/run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/log/mysql /var/lib/mysql

# Create entrypoint script
RUN echo '#!/bin/bash' > /docker-entrypoint.sh && \
    echo 'set -eo pipefail' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Initialize MySQL data directory if it does not exist' >> /docker-entrypoint.sh && \
    echo 'if [ ! -d "/var/lib/mysql/mysql" ]; then' >> /docker-entrypoint.sh && \
    echo '    echo "=== Initializing MySQL database ==="' >> /docker-entrypoint.sh && \
    echo '    gosu mysql mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql' >> /docker-entrypoint.sh && \
    echo '    echo "=== MySQL database initialized ==="' >> /docker-entrypoint.sh && \
    echo 'fi' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Start MySQL in the background' >> /docker-entrypoint.sh && \
    echo 'echo "=== Starting MySQL server ==="' >> /docker-entrypoint.sh && \
    echo 'gosu mysql mysqld --defaults-file=/etc/mysql/conf.d/custom.cnf --bind-address=0.0.0.0 --port=3307 &' >> /docker-entrypoint.sh && \
    echo 'MYSQL_PID=$!' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Wait for MySQL to be ready' >> /docker-entrypoint.sh && \
    echo 'echo "=== Waiting for MySQL to be ready ==="' >> /docker-entrypoint.sh && \
    echo 'for i in {1..60}; do' >> /docker-entrypoint.sh && \
    echo '    if mysqladmin ping --port=3307 --silent 2>/dev/null; then' >> /docker-entrypoint.sh && \
    echo '        echo "=== MySQL is ready! ==="' >> /docker-entrypoint.sh && \
    echo '        break' >> /docker-entrypoint.sh && \
    echo '    fi' >> /docker-entrypoint.sh && \
    echo '    echo "Waiting for MySQL to start... ($i/60)"' >> /docker-entrypoint.sh && \
    echo '    sleep 1' >> /docker-entrypoint.sh && \
    echo '    if [ $i -eq 60 ]; then' >> /docker-entrypoint.sh && \
    echo '        echo "ERROR: MySQL failed to start within 60 seconds"' >> /docker-entrypoint.sh && \
    echo '        exit 1' >> /docker-entrypoint.sh && \
    echo '    fi' >> /docker-entrypoint.sh && \
    echo 'done' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Check if we need to setup users (first run)' >> /docker-entrypoint.sh && \
    echo 'echo "=== Checking if setup is needed ==="' >> /docker-entrypoint.sh && \
    echo 'SETUP_NEEDED=false' >> /docker-entrypoint.sh && \
    echo 'if mysql --port=3307 -u root -e "SELECT 1" 2>/dev/null; then' >> /docker-entrypoint.sh && \
    echo '    echo "=== First run detected - will setup users and database ==="' >> /docker-entrypoint.sh && \
    echo '    SETUP_NEEDED=true' >> /docker-entrypoint.sh && \
    echo 'else' >> /docker-entrypoint.sh && \
    echo '    echo "=== MySQL already configured, skipping setup ==="' >> /docker-entrypoint.sh && \
    echo 'fi' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo 'if [ "$SETUP_NEEDED" = true ]; then' >> /docker-entrypoint.sh && \
    echo '    echo "=== Setting up MySQL users and database ==="' >> /docker-entrypoint.sh && \
    echo '    mysql --port=3307 -u root <<EOSQL' >> /docker-entrypoint.sh && \
    echo 'ALTER USER '"'"'root'"'"'@'"'"'localhost'"'"' IDENTIFIED WITH mysql_native_password BY '"'"'${MYSQL_ROOT_PASSWORD}'"'"';' >> /docker-entrypoint.sh && \
    echo 'CREATE USER IF NOT EXISTS '"'"'root'"'"'@'"'"'%'"'"' IDENTIFIED WITH mysql_native_password BY '"'"'${MYSQL_ROOT_PASSWORD}'"'"';' >> /docker-entrypoint.sh && \
    echo 'GRANT ALL PRIVILEGES ON *.* TO '"'"'root'"'"'@'"'"'%'"'"' WITH GRANT OPTION;' >> /docker-entrypoint.sh && \
    echo 'CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;' >> /docker-entrypoint.sh && \
    echo 'CREATE USER IF NOT EXISTS '"'"'${MYSQL_USER}'"'"'@'"'"'%'"'"' IDENTIFIED WITH mysql_native_password BY '"'"'${MYSQL_PASSWORD}'"'"';' >> /docker-entrypoint.sh && \
    echo 'GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '"'"'${MYSQL_USER}'"'"'@'"'"'%'"'"';' >> /docker-entrypoint.sh && \
    echo 'FLUSH PRIVILEGES;' >> /docker-entrypoint.sh && \
    echo 'EOSQL' >> /docker-entrypoint.sh && \
    echo '    echo "=== MySQL setup completed successfully! ==="' >> /docker-entrypoint.sh && \
    echo 'fi' >> /docker-entrypoint.sh && \
    echo '' >> /docker-entrypoint.sh && \
    echo '# Wait for MySQL to keep running' >> /docker-entrypoint.sh && \
    echo 'echo "=== MySQL is running and ready for connections ==="' >> /docker-entrypoint.sh && \
    echo 'wait $MYSQL_PID' >> /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

# Expose MySQL port
EXPOSE 3307

# Set the entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
