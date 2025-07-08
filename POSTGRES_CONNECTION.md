# PostgreSQL Connection Guide

## Connection Settings for DBeaver/pgAdmin

### Connection 1: Application User (Recommended)
- **Server Host**: `localhost` or `127.0.0.1`
- **Port**: `5433`
- **Database**: `myapp`
- **Username**: `appuser`
- **Password**: `apppassword`
- **Driver**: PostgreSQL
- **Driver Settings**: Leave as default

### Connection 2: Administrative User (Same as app user in this setup)
- **Server Host**: `localhost` or `127.0.0.1`
- **Port**: `5433`
- **Database**: `postgres` or `myapp`
- **Username**: `appuser`
- **Password**: `apppassword`
- **Driver**: PostgreSQL
- **Driver Settings**: Leave as default

## Troubleshooting

### Windows CloudPC Specific Notes:
- PostgreSQL server runs on port 5433 (instead of default 5432) to avoid conflicts
- The server is configured to accept connections from all interfaces
- Both MySQL and PostgreSQL run on the same Docker network for inter-service communication

### If Connection Still Fails:

1. **Check Container Status**:
   ```bash
   docker-compose ps
   ```

2. **Verify Port is Accessible**:
   ```bash
   netstat -an | findstr :5433
   ```

3. **Test Connection from Command Line**:
   ```bash
   docker exec -it postgres-container psql -U appuser -d myapp
   ```

4. **Check PostgreSQL Logs**:
   ```bash
   docker logs postgres-container
   ```

5. **Check Firewall**: Ensure Windows Firewall allows connections on port 5433

### DBeaver/pgAdmin Advanced Settings (if needed):

In connection settings, you may need to:
- Set "SSL Mode" to `disable` for local development
- Set "Show non-default DB" to `true`

## Testing Connection

You can test the connection without DBeaver using:

```bash
# Test from host machine (requires PostgreSQL client)
psql -h 127.0.0.1 -p 5433 -U appuser -d myapp

# Test from within container
docker exec -it postgres-container psql -U appuser -d myapp -c "SELECT version();"

# List all databases
docker exec -it postgres-container psql -U appuser -d myapp -c "\l"

# List all tables in myapp database
docker exec -it postgres-container psql -U appuser -d myapp -c "\dt"
```

## Available Databases

- `myapp` - Your application database (with sample tables)
- `postgres` - Default PostgreSQL system database
- `template0` - PostgreSQL template database
- `template1` - PostgreSQL template database

## Sample Tables Created

The initialization script creates these sample tables in the `myapp` database:

### `users` table:
- `id` (SERIAL PRIMARY KEY)
- `username` (VARCHAR(50) UNIQUE)
- `email` (VARCHAR(100) UNIQUE)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### `posts` table:
- `id` (SERIAL PRIMARY KEY)
- `user_id` (INTEGER, foreign key to users)
- `title` (VARCHAR(200))
- `content` (TEXT)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

## Common PostgreSQL Commands

```sql
-- Connect to database
\c myapp

-- List all tables
\dt

-- Describe table structure
\d users
\d posts

-- Show all users
SELECT * FROM users;

-- Show all posts with user information
SELECT p.title, p.content, u.username 
FROM posts p 
JOIN users u ON p.user_id = u.id;
```

## Security Notes

⚠️ **Important**: These are development credentials. For production:
1. Change all passwords
2. Use environment-specific configuration
3. Enable SSL/TLS encryption
4. Implement proper network security
5. Use connection pooling
6. Set up proper backup strategies

## Multi-Database Development

You now have both MySQL (port 3307) and PostgreSQL (port 5433) running simultaneously:

- **MySQL**: Perfect for applications that need MySQL-specific features
- **PostgreSQL**: Excellent for applications requiring advanced SQL features, JSON support, or complex queries
- **Network**: Both databases are on the same Docker network and can communicate with each other if needed
