# Multi-Database Docker Environment

This Docker setup provides both MySQL and PostgreSQL databases running in separate containers for comprehensive database development and testing.

> **📁 Important**: All infrastructure files are located in the `infrastructure/` directory. Navigate there to run Docker commands.

## Features

- **MySQL Container**: Ubuntu 22.04 with MySQL (port 3307)
- **PostgreSQL Container**: PostgreSQL 15 (port 5433)
- **dbt Container**: dbt Core with PostgreSQL adapter for data transformation
- **Pre-configured**: Ready-to-use database instances with default databases and users
- **Persistent Storage**: Data persists between container restarts for both databases
- **Sample Data**: PostgreSQL includes sample tables with test data and dbt models
- **Network Isolation**: All services run on a shared Docker network

## Database Configuration

### MySQL
- **Port**: `3307` (host) → `3307` (container)
- **Root Password**: `rootpassword`
- **Database**: `myapp`
- **User**: `appuser`
- **User Password**: `apppassword`

### PostgreSQL
- **Port**: `5433` (host) → `5432` (container)
- **Database**: `myapp`
- **User**: `appuser`
- **User Password**: `apppassword`
- **Sample Tables**: `users`, `posts` with test data

### dbt (Data Build Tool)
- **Container**: `dbt-container` 
- **dbt Version**: 1.7.4 with PostgreSQL adapter
- **Connected to**: PostgreSQL database
- **Project**: Includes staging models (`stg_users`, `stg_posts`) and marts (`user_post_summary`)
- **Profile**: Pre-configured to connect to PostgreSQL

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Navigate to infrastructure directory
cd infrastructure

# Build and start all containers (MySQL, PostgreSQL, and dbt)
docker-compose up -d

# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f mysql
docker-compose logs -f postgres
docker-compose logs -f dbt

# Stop all containers
docker-compose down

# Stop and remove volumes (WARNING: This will delete all data)
docker-compose down -v
```

### Check Container Status

```bash
# Check both containers are running (from infrastructure directory)
docker-compose ps

# Verify ports are listening
netstat -an | Select-String "3307|5433"
```

### Using Docker CLI

```bash
# Navigate to infrastructure directory
cd infrastructure

# Build the image
docker build -t mysql-custom .

# Run the container
docker run -d \
  --name mysql-container \
  -p 3307:3307 \
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

## Connecting to Databases

### dbt (Data Build Tool)

#### Run dbt Commands
```bash
# Test dbt connection to PostgreSQL
docker exec -it dbt-container dbt debug

# Run all dbt models
docker exec -it dbt-container dbt run

# Run dbt tests
docker exec -it dbt-container dbt test

# Interactive dbt shell
docker exec -it dbt-container bash
```

#### dbt Project Structure
- **Staging Models**: `stg_users`, `stg_posts` (materialized as views)
- **Marts Models**: `user_post_summary` (materialized as table)
- **Sources**: Configured to reference PostgreSQL `users` and `posts` tables
- **Tests**: Data quality tests for uniqueness, null checks, and referential integrity

### MySQL Connection

#### From Host Machine
```bash
# Using MySQL client (if installed on host)
mysql -h 127.0.0.1 -P 3307 -u appuser -p

# Using Docker exec
docker exec -it mysql-container mysql -u appuser -p
```

#### Connection Details
- **Host**: `localhost` or `127.0.0.1`
- **Port**: `3307`
- **Username**: `appuser`
- **Password**: `apppassword`
- **Database**: `myapp`

#### Root Access
- **Username**: `root`
- **Password**: `rootpassword`

### PostgreSQL Connection

#### From Host Machine
```bash
# Using PostgreSQL client (if installed on host)
psql -h 127.0.0.1 -p 5433 -U appuser -d myapp

# Using Docker exec
docker exec -it postgres-container psql -U appuser -d myapp
```

#### Connection Details
- **Host**: `localhost` or `127.0.0.1`
- **Port**: `5433`
- **Username**: `appuser`
- **Password**: `apppassword`
- **Database**: `myapp`

#### Sample Data Queries
```sql
-- List all users
SELECT * FROM users;

-- List all posts with user information
SELECT p.title, p.content, u.username 
FROM posts p 
JOIN users u ON p.user_id = u.id;

-- Query dbt staging models
SELECT * FROM stg_users;
SELECT * FROM stg_posts;

-- Query dbt marts model
SELECT * FROM user_post_summary;
```

## GUI Database Tools

For easy database management, you can use:

### DBeaver (Cross-platform)
- **MySQL**: See [infrastructure/data_sources/DBEAVER_CONNECTION.md](./infrastructure/data_sources/DBEAVER_CONNECTION.md) for detailed setup
- **PostgreSQL**: See [infrastructure/data_sinks/POSTGRES_CONNECTION.md](./infrastructure/data_sinks/POSTGRES_CONNECTION.md) for detailed setup

### Other Recommended Tools
- **pgAdmin** (PostgreSQL): Web-based administration tool
- **MySQL Workbench** (MySQL): Official MySQL GUI tool
- **phpMyAdmin** (MySQL): Web-based administration tool

## Data Persistence

- **MySQL**: Data stored in named volume `mysql_data`, logs in `./mysql-logs`
- **PostgreSQL**: Data stored in named volume `postgres_data`, logs in `./postgres-logs`
- **Network**: Both databases communicate via `database-network` bridge network
- Data persists between container restarts and rebuilds

## Windows CloudPC Optimizations

This setup is specifically optimized for Windows CloudPC environments:
- MySQL binds to `0.0.0.0:3307` for proper GUI application connectivity
- PostgreSQL configured for external connections on port 5433
- Both services avoid default ports to prevent conflicts

## Troubleshooting

### Check Container Status
```bash
# Check both containers
docker-compose ps

# Check specific container
docker ps | findstr mysql
docker ps | findstr postgres
```

### View Logs
```bash
# All services (from infrastructure directory)
docker-compose logs

# Specific service
docker-compose logs mysql
docker-compose logs postgres

# Follow logs in real-time
docker-compose logs -f mysql
docker-compose logs -f postgres
```

### Access Container Shells
```bash
# MySQL container
docker exec -it mysql-container bash

# PostgreSQL container
docker exec -it postgres-container bash
```

### Test Database Connections
```bash
# Test MySQL
docker exec mysql-container mysql -u appuser -papppassword -e "SELECT 'MySQL Connected' AS status;"

# Test PostgreSQL
docker exec postgres-container psql -U appuser -d myapp -c "SELECT 'PostgreSQL Connected' AS status;"
```

### Port Verification
```bash
# Check if ports are listening (Windows)
netstat -an | Select-String "3307|5433"

# Check if ports are listening (PowerShell alternative)
Get-NetTCPConnection | Where-Object {$_.LocalPort -eq 3307 -or $_.LocalPort -eq 5433}
```

## Security Notes

⚠️ **Important**: This setup is for development purposes. For production use:

1. **Change Default Passwords**: Update all default passwords in environment variables
2. **Network Security**: Implement proper firewall rules and network isolation
3. **SSL/TLS**: Enable encrypted connections for both MySQL and PostgreSQL
4. **Backup Strategy**: Implement automated backup procedures for both databases
5. **User Privileges**: Follow principle of least privilege for database users
6. **Monitoring**: Set up proper logging and monitoring for both database systems

## File Structure

```
docker_playground/
├── infrastructure/                 # All infrastructure files
│   ├── docker-compose.yml         # Multi-service container orchestration
│   ├── README.md                 # Infrastructure overview
│   ├── data_sources/             # Data source configurations
│   │   ├── Dockerfile            # MySQL container configuration
│   │   ├── DBEAVER_CONNECTION.md # MySQL DBeaver setup guide
│   │   └── README.md             # Data sources documentation
│   ├── data_sinks/               # Data sink configurations
│   │   ├── init-postgres.sql     # PostgreSQL initialization script
│   │   ├── POSTGRES_CONNECTION.md # PostgreSQL connection guide
│   │   └── README.md             # Data sinks documentation
│   └── dbt/                      # dbt (Data Build Tool) configurations
│       ├── Dockerfile.dbt        # dbt container configuration
│       ├── DBT_SETUP.md          # dbt setup and usage guide
│       └── README.md             # dbt documentation
├── data_transformations/          # dbt project directory (data transformation layer)
│   ├── dbt_project.yml           # dbt project configuration
│   ├── profiles.yml              # dbt connection profiles
│   ├── models/                   # dbt models
│   │   ├── staging/              # Staging models and sources
│   │   └── marts/                # Business logic models
│   └── target/                   # dbt compilation outputs
├── mysql-logs/                    # MySQL log files (created at runtime)
├── postgres-logs/                 # PostgreSQL log files (created at runtime)
├── README.md                      # This file
├── .gitignore                     # Git ignore rules
└── .git/                          # Git repository
```

## Development Scenarios

This multi-database setup supports various development scenarios:

- **Database Migration Testing**: Test applications moving from MySQL to PostgreSQL or vice versa
- **Multi-Database Applications**: Applications that need to work with both database types
- **Data Transformation**: Use dbt to build data models, transformations, and analytics
- **Learning and Comparison**: Learn differences between MySQL and PostgreSQL
- **Microservices**: Different services using different database technologies
- **Data Pipeline Development**: Build and test data pipelines with dbt
- **Data Synchronization**: Test data sync between different database systems
