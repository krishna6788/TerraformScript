#!/bin/bash
# Update package list and install PostgreSQL
sudo apt-get update
sudo apt-get install -y wget gnupg2

# Add PostgreSQL APT repository
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# Import the repository signing key and update package list again
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update

# Install the specified version of PostgreSQL server and client
sudo apt-get install  postgresql-client-common -y
sudo apt-get install  postgresql-contrib -y
sudo apt-get install  postgresql-${postgres_version} -y
sudo apt-get install  repmgr -y
# Start PostgreSQL service
sudo systemctl start postgresql
# Enable PostgreSQL to start on boot
sudo systemctl enable postgresql

# Output the status of PostgreSQL service
sudo systemctl status postgresql

            if [ "${enable_pgbackrest}" = "true" ]; then
	    sudo apt-get update
            sudo apt-get install pgbackrest -y
            # Add pgBackRest configuration here
            fi


