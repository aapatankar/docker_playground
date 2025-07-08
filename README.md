# MySQL Docker Container

This Docker setup creates a Linux container with MySQL installed and configured.

## Features

- **Base Image**: Ubuntu 22.04
- **MySQL Version**: Latest available in Ubuntu 22.04 repositories
- **Pre-configured**: Ready-to-use MySQL instance with default database and user
- **Persistent Storage**: Data persists between container restarts

## Default Configuration

- **Root Password**: `rootpassword`
- **Database**: `myapp`
- **User**: `appuser`
- **User Password**: `apppassword`
- **Port**: `3306`

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down

# Stop and remove volumes (WARNING: This will delete all data)
docker-compose down -v
```

### Using Docker CLI

```bash
# Build the image
docker build -t mysql-custom .

# Run the container
docker run -d \
  --name mysql-container \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=myapp \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppassword \
  mysql-custom

# View logs
docker logs -f mysql-container

# Stop the container
docker stop mysql-container

# Remove the container
docker rm mysql-container
```

## Connecting to MySQL

### From Host Machine

```bash
# Using MySQL client (if installed on host)
mysql -h 127.0.0.1 -P 3306 -u appuser -p

# Using Docker exec
docker exec -it mysql-container mysql -u appuser -p
```

### Connection Details

- **Host**: `localhost` or `127.0.0.1`
- **Port**: `3306`
- **Username**: `appuser`
- **Password**: `apppassword`
- **Database**: `myapp`

### Root Access

- **Username**: `root`
- **Password**: `rootpassword`

## Customization

You can customize the MySQL setup by modifying the environment variables in the `docker-compose.yml` file or when running with Docker CLI:

- `MYSQL_ROOT_PASSWORD`: Root user password
- `MYSQL_DATABASE`: Default database name
- `MYSQL_USER`: Application user name
- `MYSQL_PASSWORD`: Application user password

## Data Persistence

- When using Docker Compose, data is stored in a named volume `mysql_data`
- MySQL logs are mapped to `./mysql-logs` directory on the host
- Data persists between container restarts and rebuilds

## Troubleshooting

### Check Container Status
```bash
docker-compose ps
```

### View Logs
```bash
docker-compose logs mysql
```

### Access Container Shell
```bash
docker exec -it mysql-container bash
```

### Check MySQL Service Status (inside container)
```bash
docker exec -it mysql-container service mysql status
```

## Security Notes

⚠️ **Important**: This setup is for development purposes. For production use:

1. Change default passwords
2. Limit network access
3. Use proper SSL/TLS configuration
4. Implement proper backup strategies
5. Follow MySQL security best practices
