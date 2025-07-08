# Infrastructure Directory

This directory contains all the Docker infrastructure files for the multi-database environment.

## Files

- **`docker-compose.yml`** - Orchestrates both MySQL and PostgreSQL containers
- **`Dockerfile`** - Custom MySQL container configuration
- **`init-postgres.sql`** - PostgreSQL initialization script with sample data
- **`DBEAVER_CONNECTION.md`** - MySQL connection guide for DBeaver
- **`POSTGRES_CONNECTION.md`** - PostgreSQL connection guide

## Quick Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Rebuild and restart
docker-compose up -d --build

# Check status
docker-compose ps
```

## Database Access

### MySQL
- **Port**: 3307
- **User**: appuser
- **Password**: apppassword
- **Database**: myapp

### PostgreSQL
- **Port**: 5433
- **User**: appuser
- **Password**: apppassword
- **Database**: myapp (with sample data)

## Log Files

Log files are stored in the parent directory:
- `../mysql-logs/` - MySQL logs
- `../postgres-logs/` - PostgreSQL logs

## Network

Both databases communicate via the `infrastructure_database-network` Docker bridge network.

---

For complete documentation, see the main [README.md](../README.md) in the parent directory.
