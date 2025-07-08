# Data Sources

This folder contains configuration files for data source systems - databases and services that provide input data for the dbt pipeline.

## Contents

- **`Dockerfile`** - MySQL container configuration
  - Ubuntu 22.04 base with MySQL 8.0
  - Configured for port 3307 to avoid conflicts
  - Sets up `myapp` database with `appuser`
  
- **`DBEAVER_CONNECTION.md`** - MySQL connection guide for DBeaver
  - Step-by-step setup instructions
  - Connection parameters and troubleshooting

## MySQL Configuration

- **Host**: `localhost`
- **Port**: `3307` 
- **Database**: `myapp`
- **User**: `appuser`
- **Password**: `apppassword`
- **Root Password**: `rootpassword`

## Usage

The MySQL container serves as a data source in this multi-database environment. While the current dbt project connects to PostgreSQL, MySQL can be used for:

- Cross-database data integration scenarios
- Migration testing between MySQL and PostgreSQL
- Multi-source data pipeline development
- Comparative database performance analysis

## Docker Build Context

When referenced from `docker-compose.yml`, the build context is set to the parent `infrastructure` directory to ensure access to shared configuration files.
