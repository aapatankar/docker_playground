-- PostgreSQL Initialization Script
-- This script runs automatically when the container starts for the first time

-- Create additional user with administrative privileges (if needed)
-- Note: POSTGRES_USER from environment already creates the main user

-- Grant necessary privileges to appuser
GRANT ALL PRIVILEGES ON DATABASE myapp TO appuser;

-- Create some sample tables for testing
\c myapp;

-- Create a sample table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create another sample table
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(200) NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some sample data
INSERT INTO users (username, email) VALUES 
    ('testuser1', 'test1@example.com'),
    ('testuser2', 'test2@example.com')
ON CONFLICT (username) DO NOTHING;

INSERT INTO posts (user_id, title, content) VALUES 
    (1, 'First Post', 'This is the content of the first post'),
    (1, 'Second Post', 'This is the content of the second post'),
    (2, 'Hello World', 'Hello from user 2')
ON CONFLICT DO NOTHING;

-- Grant permissions on tables to appuser
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO appuser;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at);
