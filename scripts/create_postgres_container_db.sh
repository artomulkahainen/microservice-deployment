#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker before running this script."
    exit 1
fi

container_name="microservices-postgres"  # Set the container name

# Read user input for database details
read -p "Enter the desired database name: " db_name
read -p "Enter the desired PostgreSQL username: " db_user
read -s -p "Enter the desired PostgreSQL password: " db_password
echo

# Check if the PostgreSQL container is already running
if docker ps -a --format '{{.Names}}' | grep -q "^$container_name$"; then
    echo "Container '$container_name' is already running."

    # Create the new database and user within the container
    docker exec -it "$container_name" psql -U postgres -c "CREATE DATABASE $db_name;"
    docker exec -it "$container_name" psql -U postgres -c "CREATE USER $db_user WITH ENCRYPTED PASSWORD '$db_password';"
    docker exec -it "$container_name" psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $db_name TO $db_user;"

    echo "Database '$db_name' with user '$db_user' created in existing container '$container_name'."
else
    # Create a new PostgreSQL container
    docker run --name "$container_name" -e POSTGRES_DB="$db_name" -e POSTGRES_USER="$db_user" -e POSTGRES_PASSWORD="$db_password" -p 5432:5432 -d postgres:14
    echo "PostgreSQL container '$container_name' created and running with database '$db_name' and user '$db_user'."
fi
