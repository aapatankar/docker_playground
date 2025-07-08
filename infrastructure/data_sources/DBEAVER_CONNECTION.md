# DBeaver Connection Guide

## Connection Settings for DBeaver

### Connection 1: Application User (Recommended)
- **Server Host**: `localhost` or `127.0.0.1`
- **Port**: `3307`
- **Database**: `myapp`
- **Username**: `appuser`
- **Password**: `apppassword`
- **Driver**: MySQL
- **Driver Settings**: Leave as default

### Connection 2: Root User (Administrative)
- **Server Host**: `localhost` or `127.0.0.1`
- **Port**: `3307`
- **Database**: (leave empty or use `mysql`)
- **Username**: `root`
- **Password**: `rootpassword`
- **Driver**: MySQL
- **Driver Settings**: Leave as default

## Troubleshooting

### Windows CloudPC Specific Notes:
- This MySQL setup is optimized for Windows CloudPC environments
- The server binds to `0.0.0.0:3307` to ensure proper connectivity from GUI applications
- Port 3307 is used instead of the default 3306 to avoid conflicts

### If Connection Still Fails:

1. **Check Container Status**:
   ```bash
   docker-compose ps
   ```

2. **Verify Port is Accessible**:
   ```bash
   netstat -an | findstr :3307
   ```

3. **Test Connection from Command Line**:
   ```bash
   docker exec -it mysql-container mysql -u appuser -papppassword
   ```

4. **Check Firewall**: Ensure Windows Firewall allows connections on port 3307

5. **SSL Settings**: In DBeaver advanced settings, try:
   - Set "useSSL" to `false`
   - Set "allowPublicKeyRetrieval" to `true`

### DBeaver Advanced Settings (if needed):

In DBeaver connection settings, go to "Driver properties" and add:
- `useSSL`: `false`
- `allowPublicKeyRetrieval`: `true`
- `serverTimezone`: `UTC`

## Testing Connection

You can test the connection without DBeaver using:

```bash
# Test from host machine (requires MySQL client)
mysql -h 127.0.0.1 -P 3307 -u appuser -papppassword

# Test from within container
docker exec -it mysql-container mysql -u appuser -papppassword -e "SHOW DATABASES;"
```

## Available Databases

- `myapp` - Your application database
- `information_schema` - MySQL system information
- `performance_schema` - MySQL performance data
- `sys` - MySQL system database (if using root user)

## Security Notes

⚠️ **Important**: These are development credentials. For production:
1. Change all passwords
2. Limit user privileges
3. Use SSL/TLS encryption
4. Implement proper network security
