# Data Sinks

This folder contains configuration files for data sink systems - databases and services that store processed data outputs from the dbt pipeline.

## Contents

- **`init-postgres.sql`** - PostgreSQL initialization script
  - Creates sample tables (`users`, `posts`)
  - Inserts test data for dbt processing
  - Sets up proper permissions and indexes
  
- **`POSTGRES_CONNECTION.md`** - PostgreSQL connection guide
  - Connection parameters and setup instructions
  - Integration with various database tools

## PostgreSQL Configuration

- **Host**: `localhost`
- **Port**: `5433`
- **Database**: `myapp`
- **User**: `appuser` 
- **Password**: `apppassword`

## Sample Data Structure

### Users Table
- `id` (SERIAL PRIMARY KEY)
- `username` (VARCHAR, UNIQUE)
- `email` (VARCHAR, UNIQUE)
- `created_at`, `updated_at` (TIMESTAMP)

### Posts Table
- `id` (SERIAL PRIMARY KEY)
- `user_id` (INTEGER, FOREIGN KEY)
- `title` (VARCHAR)
- `content` (TEXT)
- `created_at`, `updated_at` (TIMESTAMP)

## dbt Integration

PostgreSQL serves as the primary data warehouse for this dbt project:

- **Source Tables**: `users`, `posts` (raw data)
- **Staging Models**: `stg_users`, `stg_posts` (cleaned data views)
- **Marts Models**: `user_post_summary` (aggregated business metrics)

## Initialization Process

The `init-postgres.sql` script runs automatically when the PostgreSQL container starts for the first time, setting up:

1. Database schema and tables
2. Sample test data
3. User permissions
4. Performance indexes
5. Data quality constraints

This provides a complete working dataset for dbt model development and testing.
