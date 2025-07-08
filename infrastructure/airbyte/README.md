# Airbyte Setup with abctl

This directory contains documentation for setting up Airbyte using the `abctl` command-line tool. The `abctl` tool provides a simplified way to deploy Airbyte locally using Docker and Kubernetes (kind).

## Prerequisites

- **Docker**: Ensure Docker Desktop is installed and running
- **abctl**: The Airbyte CLI tool (installation instructions below)

## Installing abctl

### Windows (PowerShell)

```powershell
# Download and install abctl
curl -LsfS https://get.airbyte.com | powershell
```

### macOS/Linux

```bash
# Download and install abctl
curl -LsfS https://get.airbyte.com | bash
```

### Manual Installation

1. Download the latest release from: https://github.com/airbytehq/abctl/releases
2. Extract and add to your PATH

## Quick Start

### 1. Install Airbyte Locally

```bash
# Deploy Airbyte with all required components
abctl local install
```

This command will:
- Install Docker and Kubernetes (kind) if not present
- Deploy Airbyte using Helm charts
- Set up nginx ingress controller
- Create all necessary services and volumes

### 2. Access Airbyte

Once installation is complete:
- **Web UI**: http://localhost:8000
- **API**: http://localhost:8001

### 3. Get Login Credentials

```bash
# Retrieve your admin credentials
abctl local credentials
```

Example output:
```
Email: your-email@domain.com
Password: generated-password
Client-Id: client-id-uuid
Client-Secret: client-secret
```

## Managing Your Airbyte Installation

### Check Status

```bash
# View current status
abctl local status

# List all deployments
abctl local deployments
```

### Stop/Start Services

```bash
# Uninstall Airbyte (preserves data)
abctl local uninstall

# Reinstall Airbyte
abctl local install
```

## Services Deployed

The `abctl` installation includes:

- **airbyte-abctl-server** - Core Airbyte API server
- **airbyte-abctl-webapp** - Web interface
- **airbyte-abctl-worker** - Job execution worker
- **airbyte-abctl-temporal** - Workflow orchestration
- **airbyte-abctl-connector-builder-server** - Custom connector builder
- **airbyte-abctl-cron** - Scheduled job management
- **airbyte-abctl-workload-api-server** - Workload management API
- **airbyte-abctl-workload-launcher** - Workload launcher service

## Configuration

### Default Settings

- **Database**: PostgreSQL (managed internally)
- **Storage**: Persistent volumes for data retention
- **Network**: Kubernetes networking with ingress
- **Authentication**: Email/password authentication enabled

### Connecting to External Databases

When setting up sources and destinations in Airbyte:

#### PostgreSQL (Your Data Sink)
- **Host**: `host.docker.internal` (from Airbyte containers)
- **Port**: `5433`
- **Database**: `myapp`
- **Username**: `appuser`
- **Password**: `apppassword`

#### MySQL (Your Data Source)
- **Host**: `host.docker.internal` (from Airbyte containers)
- **Port**: `3307`
- **Database**: `your-mysql-db`
- **Username**: Your MySQL credentials
- **Password**: Your MySQL credentials

## Architecture Overview

```
┌─────────────┐    ┌─────────────┐    ┌──────────────┐
│   MySQL     │    │   Airbyte   │    │ PostgreSQL   │
│ (Data Source)│───▶│   (abctl)   │───▶│(Data Lake)   │
│   Port 3307 │    │ Port 8000   │    │  Port 5433   │
└─────────────┘    └─────────────┘    └──────────────┘
                           │
                           ▼
                   ┌─────────────┐
                   │     dbt     │
                   │(Transforms) │
                   │             │
                   └─────────────┘
```

## Data Flow

1. **Source**: MySQL container (`host.docker.internal:3307`)
2. **Extraction**: Airbyte reads data from MySQL
3. **Loading**: Data loaded into PostgreSQL (`host.docker.internal:5433`)
4. **Schema**: Raw data stored in `raw_data` schema
5. **Transformation**: dbt processes raw data into analytical models

## Troubleshooting

### Installation Issues

1. **Docker not running**:
   ```bash
   # Start Docker Desktop and try again
   abctl local install
   ```

2. **Port conflicts**:
   ```bash
   # Check what's using ports 8000/8001
   netstat -an | findstr ":8000"
   netstat -an | findstr ":8001"
   ```

3. **Kubernetes issues**:
   ```bash
   # Check kind cluster
   docker ps | findstr kind
   
   # Reset if needed
   abctl local uninstall
   abctl local install
   ```

### Runtime Issues

1. **Cannot access Web UI**:
   - Ensure Docker is running
   - Check `abctl local status`
   - Verify http://localhost:8000 is accessible

2. **Login issues**:
   - Get fresh credentials: `abctl local credentials`
   - Clear browser cache and try again

3. **Connection to databases fails**:
   - Use `host.docker.internal` instead of `localhost`
   - Verify your database containers are running
   - Check network connectivity

### Logs and Debugging

```bash
# Check abctl version
abctl version

# View detailed installation logs
abctl local install --verbose

# Get Kubernetes context info
kubectl config current-context

# View pod logs (if familiar with kubectl)
kubectl logs -l app=airbyte-server
```

## Data Persistence

- **Data Location**: All Airbyte data is stored in Kubernetes persistent volumes
- **Backup**: Use `kubectl` commands to backup persistent volumes if needed
- **Reset**: Run `abctl local uninstall` followed by `abctl local install` for clean reset

## Advantages of abctl over Docker Compose

1. **Simplified Management**: Single command installation and management
2. **Production-Like**: Uses Kubernetes and Helm (production tools)
3. **Automatic Updates**: Easier to update to newer Airbyte versions
4. **Better Resource Management**: Kubernetes handles resource allocation
5. **Service Discovery**: Built-in service discovery and networking
6. **Health Checks**: Automatic health monitoring and restart policies

## Security Notes

⚠️ **Important**: This is a local development setup:

1. **Credentials**: Store credentials securely, don't commit to version control
2. **Network**: Only accessible from localhost by default
3. **Production**: Use proper Kubernetes deployment for production environments
4. **SSL**: Consider enabling SSL for production deployments

## Use Cases

1. **Data Lake Creation**: Centralize data from multiple MySQL sources
2. **Real-time Sync**: Keep PostgreSQL updated with MySQL changes
3. **Data Migration**: Move data between database systems
4. **Analytics Preparation**: Stage data for dbt transformations
5. **Backup & Replication**: Create redundant data copies

## Commands Reference

```bash
# Install Airbyte
abctl local install

# Check status
abctl local status
abctl local deployments

# Get credentials
abctl local credentials

# Uninstall (preserves data)
abctl local uninstall

# View help
abctl --help
abctl local --help

# Version info
abctl version
```

## Additional Resources

- **Airbyte Documentation**: https://docs.airbyte.com/
- **abctl GitHub**: https://github.com/airbytehq/abctl
- **Connector Catalog**: https://docs.airbyte.com/integrations/
- **API Documentation**: http://localhost:8001/api/v1/docs (when running)

## Migration from Docker Compose

If you previously used Docker Compose for Airbyte:

1. **Stop Docker Compose**: `docker-compose down -v`
2. **Install abctl**: Follow installation instructions above
3. **Deploy with abctl**: `abctl local install`
4. **Access UI**: http://localhost:8000 (same as before)
5. **Reconfigure connections**: Use `host.docker.internal` for database hosts

The `abctl` approach provides better stability, easier management, and production-like deployment patterns compared to Docker Compose.
