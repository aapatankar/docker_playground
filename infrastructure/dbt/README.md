# dbt (Data Build Tool)

This folder contains configuration files for the dbt (Data Build Tool) container and setup documentation.

## Contents

- **`Dockerfile.dbt`** - dbt container configuration
  - Based on Python 3.11 slim image
  - Installs dbt Core with PostgreSQL adapter (version 1.7.4)
  - Sets up working directory and profiles path
  
- **`DBT_SETUP.md`** - dbt setup and usage guide
  - Installation and configuration instructions
  - Command reference and best practices
  - Project structure documentation

## dbt Container Configuration

### Base Image
- **Python**: 3.11-slim
- **dbt Core**: 1.7.4
- **dbt Adapter**: dbt-postgres 1.7.4

### Environment Setup
- **Working Directory**: `/dbt/project`
- **Profiles Directory**: `/dbt/profiles`
- **Target Directory**: `/dbt/project/target` (mounted as volume)

### Mounted Volumes
- `../data_transformations:/dbt/project` - Main dbt project directory
- `../data_transformations/profiles.yml:/dbt/profiles/profiles.yml` - Database connection profiles
- `dbt_target:/dbt/project/target` - Compiled artifacts and logs

## dbt Project Structure

The dbt container connects to the separate `data_transformations/` directory containing:

### Core Configuration
- **`dbt_project.yml`** - Project configuration and model settings
- **`profiles.yml`** - Database connection profiles

### Models
- **`models/staging/`** - Staging models (`stg_users`, `stg_posts`)
- **`models/marts/`** - Business logic models (`user_post_summary`)
- **`models/staging/sources.yml`** - Source table definitions

### Compiled Artifacts
- **`target/`** - Compiled SQL, documentation, and run logs

## Common dbt Commands

```bash
# Test database connection
docker exec -it dbt-container dbt debug

# Run all models
docker exec -it dbt-container dbt run

# Run data quality tests
docker exec -it dbt-container dbt test

# Generate documentation
docker exec -it dbt-container dbt docs generate

# Interactive shell
docker exec -it dbt-container bash
```

## Database Connection

The dbt container connects to the PostgreSQL container (`postgres-container`) in the same Docker network:

- **Host**: `postgres-container`
- **Port**: `5432`
- **Database**: `myapp`
- **User**: `appuser`
- **Schema**: `public`

## Data Pipeline Flow

1. **Source Data**: PostgreSQL tables (`users`, `posts`)
2. **Staging Models**: Clean and standardize raw data
3. **Marts Models**: Apply business logic and create aggregations
4. **Tests**: Validate data quality and integrity
5. **Documentation**: Auto-generated data catalog

This setup provides a complete modern data stack with version-controlled transformations, testing, and documentation.
