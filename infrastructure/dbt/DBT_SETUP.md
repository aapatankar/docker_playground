# DBT Setup Guide

This guide covers the dbt (Data Build Tool) project that works with the PostgreSQL database. The dbt project is located in the `../dbt_project/` directory at the root level of the repository.

## What's Included

- **dbt Container**: Python 3.11 with dbt-postgres adapter
- **Sample Models**: Staging and mart models using the existing PostgreSQL data
- **Connection Configuration**: Pre-configured to connect to the postgres-container

## Quick Start

### 1. Start All Services
```bash
# Make sure you're in the infrastructure directory
docker-compose up -d
```

### 2. Access dbt Container
```bash
# Connect to the dbt container
docker exec -it dbt-container bash
```

### 3. Initialize dbt (First Time Only)
```bash
# Inside the dbt container
dbt debug  # Test connection
dbt deps   # Install dependencies (if any)
```

### 4. Run dbt Models
```bash
# Run all models
dbt run

# Run specific model
dbt run --select stg_users

# Run tests
dbt test

# Generate and serve documentation
dbt docs generate
dbt docs serve --host 0.0.0.0 --port 8080
```

## Project Structure

```
../dbt_project/                 # dbt project (at repository root level)
├── dbt_project.yml             # dbt project configuration
├── profiles.yml               # dbt connection profiles
├── models/
│   ├── staging/
│   │   ├── sources.yml         # Source table definitions
│   │   ├── stg_users.sql       # Staging view for users
│   │   └── stg_posts.sql       # Staging view for posts
│   └── marts/
│       └── user_post_summary.sql  # Analytics table
├── tests/                      # Custom tests (if any)
├── macros/                     # Custom macros (if any)
└── target/                     # Compiled SQL and artifacts
```

## Sample Models

### Staging Models
- **stg_users**: Clean view of the users table
- **stg_posts**: Clean view of the posts table

### Mart Models
- **user_post_summary**: Aggregated table showing user post statistics

## Common dbt Commands

```bash
# Test database connection
dbt debug

# Run all models
dbt run

# Run specific model
dbt run --select user_post_summary

# Run staging models only
dbt run --select staging

# Run tests
dbt test

# Run specific test
dbt test --select stg_users

# Generate documentation
dbt docs generate

# Serve documentation (access at http://localhost:8080)
dbt docs serve --host 0.0.0.0 --port 8080

# Compile models without running
dbt compile

# Clean compiled files
dbt clean
```

## Connection Details

The dbt project is configured to connect to:
- **Host**: postgres-container (Docker internal network)
- **Port**: 5432
- **Database**: myapp
- **User**: appuser
- **Password**: apppassword
- **Schema**: public (for dev), analytics (for prod)

## Development Workflow

1. **Create new models** in `../dbt_project/models/` directory
2. **Test locally** with `dbt run --select your_model`
3. **Add tests** in `sources.yml` or separate test files
4. **Run full pipeline** with `dbt run && dbt test`
5. **Generate docs** with `dbt docs generate && dbt docs serve`

## Adding New Models

To add a new model:

1. Create a new `.sql` file in the appropriate directory (`../dbt_project/models/staging/` or `../dbt_project/models/marts/`)
2. Use dbt syntax and Jinja templating
3. Reference other models with `{{ ref('model_name') }}`
4. Reference source tables with `{{ source('schema', 'table') }}`

Example:
```sql
-- models/marts/my_new_model.sql
{{ config(materialized='table') }}

select
    column1,
    column2,
    count(*) as record_count
from {{ ref('stg_users') }}
group by column1, column2
```

## Troubleshooting

### Connection Issues
```bash
# Test connection
dbt debug

# Check if postgres is accessible
docker exec dbt-container ping postgres-container
```

### Permission Issues
```bash
# Check if user has correct permissions
docker exec postgres-container psql -U appuser -d myapp -c "\dp"
```

### Model Failures
```bash
# Run with verbose logging
dbt run --select failing_model --log-level debug

# Check compiled SQL
dbt compile --select failing_model
cat target/compiled/postgres_analytics/models/path/to/model.sql
```
