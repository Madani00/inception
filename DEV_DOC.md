<div align="center">

# 🔧 Inception - Developer Documentation

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Docker Compose](https://img.shields.io/badge/Docker_Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)

**Complete technical guide for developers**

</div>

---

## 📋 Table of Contents

- [🛠️ Environment Setup](#️-environment-setup)
- [🏗️ Building and Launching](#️-building-and-launching)
- [🐳 Container Management](#-container-management)
- [💾 Volume Management](#-volume-management)
- [📦 Data Persistence](#-data-persistence)
- [🔍 Debugging and Development](#-debugging-and-development)
- [🏛️ Architecture Deep Dive](#️-architecture-deep-dive)

---

## 🛠️ Environment Setup

### Prerequisites Installation

#### 1. Install Docker

```bash
# Update package index
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Add user to docker group (to run without sudo)
sudo usermod -aG docker $USER

# Apply group changes (or logout/login)
newgrp docker

# Verify installation
docker --version
# Expected: Docker version 20.10.0 or higher
```

#### 2. Install Docker Compose

```bash
# Install Docker Compose
sudo apt-get install -y docker-compose

# Verify installation
docker-compose --version
# Expected: docker-compose version 1.29.0 or higher
```

#### 3. Install Make

```bash
# Install Make utility
sudo apt-get install -y make

# Verify installation
make --version
# Expected: GNU Make 4.2 or higher
```

#### 4. System Requirements

- **OS:** Linux (Debian/Ubuntu recommended)
- **RAM:** Minimum 2GB, recommended 4GB+
- **Disk:** Minimum 5GB free space
- **CPU:** 2 cores recommended

### Configuration Files Setup

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd push_incept
```

#### 2. Create Environment File

The `.env` file stores all environment variables and secrets:

```bash
# Create .env file in srcs/ directory
cd srcs/
touch .env
chmod 600 .env  # Restrict permissions
```

#### 3. Configure Environment Variables

Edit `srcs/.env` with required variables:

```bash
nano .env
```

**Minimum required configuration:**

```env
# ==========================================
# DOMAIN CONFIGURATION
# ==========================================
DOMAIN_NAME=eamchart.42.fr

# ==========================================
# MARIADB CONFIGURATION
# ==========================================
MYSQL_ROOT_PASSWORD=<strong_root_password>
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=<strong_db_password>

# ==========================================
# WORDPRESS CONFIGURATION
# ==========================================
WP_ADMIN_NAME=admin
WP_ADMIN_PASSWORD=<strong_admin_password>
WP_ADMIN_MAIL=admin@example.com

WP_USER_NAME=editor
WP_USER_MAIL=editor@example.com
WP_USER_PASSWORD=<strong_user_password>

# ==========================================
# WORDPRESS DATABASE CONNECTION
# ==========================================
WP_DB_NAME=${MYSQL_DATABASE}
WP_DB_USER=${MYSQL_USER}
WP_DB_PASSWORD=${MYSQL_PASSWORD}
WP_DB_HOST=mariadb:3306

# ==========================================
# REDIS CONFIGURATION (if bonus)
# ==========================================
REDIS_HOST=redis
REDIS_PORT=6379

# ==========================================
# FTP CONFIGURATION (if bonus)
# ==========================================
FTP_USER=ftpuser
FTP_PASSWORD=<strong_ftp_password>
```

#### 4. Configure Hosts File

Add domain to `/etc/hosts` for local testing:

```bash
sudo nano /etc/hosts

# Add this line:
127.0.0.1 eamchart.42.fr
```

#### 5. Create Volume Directories

```bash
# Create directories for persistent data
sudo mkdir -p /home/$USER/data/wordpress
sudo mkdir -p /home/$USER/data/mariadb

# Set proper ownership
sudo chown -R $USER:$USER /home/$USER/data/

# Verify creation
ls -la /home/$USER/data/
```

### Secrets Management

**Important:** Never commit secrets to version control!

```bash
# Add .env to .gitignore
echo "srcs/.env" >> .gitignore

# Create .env.example template (without actual secrets)
cp srcs/.env srcs/.env.example
# Then edit .env.example to replace secrets with placeholders
```

---

## 🏗️ Building and Launching

### Using Makefile (Recommended)

The Makefile provides convenient commands for managing the project:

#### Build and Start

```bash
# Build all images and start containers
make

# This is equivalent to:
# make build && make up
```

#### Start Services

```bash
# Start all containers in detached mode
make up
```

#### Stop Services

```bash
# Stop and remove containers
make down
```

#### Rebuild Everything

```bash
# Clean everything and rebuild from scratch
make re

# This is equivalent to:
# make fclean && make
```

### Using Docker Compose Directly

For more control, use docker-compose commands:

#### Build Images

```bash
cd srcs/

# Build all images
docker-compose build

# Build specific service
docker-compose build nginx

# Build without cache (forces rebuild)
docker-compose build --no-cache

# Build with parallel processing
docker-compose build --parallel
```

#### Start Containers

```bash
# Start in detached mode
docker-compose up -d

# Start with build
docker-compose up -d --build

# Start specific services
docker-compose up -d nginx wordpress mariadb

# Start in foreground (see logs)
docker-compose up
```

#### Stop Containers

```bash
# Stop containers (keep them)
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove containers + volumes
docker-compose down -v

# Stop and remove everything including images
docker-compose down --rmi all -v
```

### Build Process Explained

#### What Happens During Build:

1. **Image Building:**
   - Reads each Dockerfile in `requirements/`
   - Downloads base image (Debian Bullseye)
   - Installs required packages
   - Copies configuration files
   - Sets up entrypoint scripts

2. **Network Creation:**
   - Creates bridge network "inception"
   - Connects all containers to this network

3. **Volume Creation:**
   - Creates named volumes for persistence
   - Mounts volumes to containers

4. **Container Launch:**
   - Starts containers in dependency order
   - MariaDB → WordPress → Nginx
   - Runs initialization scripts

#### Build Order:

```mermaid
MariaDB Container
    ↓
(Wait for DB ready)
    ↓
WordPress Container
    ↓
(Wait for WP ready)
    ↓
Nginx Container
    ↓
Bonus Services (if enabled)
```

---

## 🐳 Container Management

### Viewing Container Status

```bash
# List all containers
docker ps -a

# Show only running containers
docker ps

# Show with custom format
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Using Makefile
make ps
```

### Starting and Stopping Individual Containers

```bash
# Start specific container
docker start nginx
docker start wordpress
docker start mariadb

# Stop specific container
docker stop nginx
docker stop wordpress
docker stop mariadb

# Restart container
docker restart nginx
```

### Accessing Container Shells

```bash
# Access Nginx container
docker exec -it nginx /bin/bash

# Access WordPress container
docker exec -it wordpress /bin/bash

# Access MariaDB container
docker exec -it mariadb /bin/bash

# Access as specific user
docker exec -it -u www-data wordpress /bin/bash

# Run one-off command
docker exec nginx ls -la /etc/nginx
```

### Viewing Container Logs

```bash
# View all logs
docker-compose -f srcs/docker-compose.yml logs

# Follow logs in real-time
docker-compose -f srcs/docker-compose.yml logs -f

# View specific service logs
docker logs nginx
docker logs wordpress
docker logs mariadb

# Follow specific service
docker logs -f nginx

# Show last N lines
docker logs --tail 50 nginx

# Show logs since timestamp
docker logs --since 30m nginx

# Using Makefile
make logs
```

### Inspecting Containers

```bash
# Inspect container configuration
docker inspect nginx

# Get specific information (IP address)
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx

# Get environment variables
docker inspect -f '{{.Config.Env}}' wordpress

# Get mount points
docker inspect -f '{{.Mounts}}' wordpress
```

### Resource Monitoring

```bash
# View real-time resource usage
docker stats

# View specific containers
docker stats nginx wordpress mariadb

# Show only specific fields
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Container Cleanup

```bash
# Remove stopped containers
docker container prune

# Remove all containers (dangerous!)
docker rm -f $(docker ps -aq)

# Remove specific container
docker rm -f nginx

# Using Makefile
make clean      # Remove containers
make fclean     # Remove containers + volumes
make fcleanall  # Complete cleanup
```

---

## 💾 Volume Management

### Viewing Volumes

```bash
# List all volumes
docker volume ls

# Inspect specific volume
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb

# Show volume usage
docker system df -v
```

### Volume Locations

#### Named Volumes (Managed by Docker)

```bash
# Default location on host
/var/lib/docker/volumes/

# Inception volumes:
/var/lib/docker/volumes/srcs_wordpress/_data
/var/lib/docker/volumes/srcs_mariadb/_data
```

#### Bind Mounts (Direct Host Paths)

```bash
# WordPress files
/home/$USER/data/wordpress/

# MariaDB data
/home/$USER/data/mariadb/
```

### Volume Operations

```bash
# Create volume manually
docker volume create my_volume

# Remove volume
docker volume rm srcs_wordpress

# Remove all unused volumes
docker volume prune

# Remove all volumes (dangerous!)
docker volume rm $(docker volume ls -q)
```

### Backup Volumes

```bash
# Backup WordPress volume
docker run --rm \
  -v srcs_wordpress:/data \
  -v $(pwd):/backup \
  debian:bullseye \
  tar czf /backup/wordpress-backup.tar.gz -C /data .

# Backup MariaDB volume
docker run --rm \
  -v srcs_mariadb:/data \
  -v $(pwd):/backup \
  debian:bullseye \
  tar czf /backup/mariadb-backup.tar.gz -C /data .

# Or backup database directly
docker exec mariadb mysqldump -u root -p${MYSQL_ROOT_PASSWORD} \
  --all-databases > backup.sql
```

### Restore Volumes

```bash
# Restore WordPress volume
docker run --rm \
  -v srcs_wordpress:/data \
  -v $(pwd):/backup \
  debian:bullseye \
  tar xzf /backup/wordpress-backup.tar.gz -C /data

# Restore database
docker exec -i mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD} \
  < backup.sql
```

---

## 📦 Data Persistence

### Where Data is Stored

#### WordPress Data

**Location:** `/var/www/html` (inside container)  
**Volume:** `srcs_wordpress` or `/home/$USER/data/wordpress`

**Contents:**
```
/var/www/html/
├── wp-admin/              # WordPress admin interface
├── wp-content/
│   ├── themes/            # Installed themes
│   ├── plugins/           # Installed plugins
│   └── uploads/           # Media files
├── wp-includes/           # WordPress core files
├── wp-config.php          # WordPress configuration
└── index.php              # Entry point
```

**Access:**
```bash
# View WordPress files
docker exec wordpress ls -la /var/www/html

# Access from host (if using bind mount)
ls -la /home/$USER/data/wordpress/
```

#### MariaDB Data

**Location:** `/var/lib/mysql` (inside container)  
**Volume:** `srcs_mariadb` or `/home/$USER/data/mariadb`

**Contents:**
```
/var/lib/mysql/
├── wordpress/             # WordPress database
│   ├── wp_posts.ibd
│   ├── wp_users.ibd
│   └── ...
├── mysql/                 # System database
├── performance_schema/    # Performance monitoring
└── ib_logfile*           # InnoDB logs
```

**Access:**
```bash
# View database files
docker exec mariadb ls -la /var/lib/mysql

# Connect to database
docker exec -it mariadb mysql -u root -p
```

#### Redis Data (if bonus)

**Location:** `/data` (inside container)  
**Volume:** `srcs_redis` (optional)

**Contents:**
- `dump.rdb` - Redis snapshot file
- `appendonly.aof` - Append-only file (if AOF enabled)

### How Persistence Works

#### Docker Volumes

1. **Creation:**
   ```yaml
   volumes:
     wordpress:
       driver: local
       driver_opts:
         type: none
         device: /home/$USER/data/wordpress
         o: bind
   ```

2. **Mounting:**
   ```yaml
   services:
     wordpress:
       volumes:
         - wordpress:/var/www/html
   ```

3. **Persistence:**
   - Data survives container deletion
   - Data persists across rebuilds
   - Data can be backed up/restored

#### What Persists vs What Doesn't

✅ **Persists (stored in volumes):**
- WordPress uploads and media
- WordPress themes and plugins
- Database tables and content
- WordPress configuration (wp-config.php)
- Redis cache data (if persistence enabled)

❌ **Does NOT persist (container layer):**
- Installed system packages
- Container logs (unless configured)
- Temporary files in `/tmp`
- Process states

### Verifying Data Persistence

```bash
# 1. Create test data
docker exec wordpress touch /var/www/html/test.txt
docker exec wordpress ls /var/www/html/test.txt

# 2. Stop and remove containers
make down

# 3. Restart containers
make up

# 4. Verify data still exists
docker exec wordpress ls /var/www/html/test.txt
# File should still be there!
```

---

## 🔍 Debugging and Development

### Debug Mode

Enable verbose logging for troubleshooting:

```bash
# View build process
docker-compose build --progress=plain

# View startup logs
docker-compose up

# Enable WordPress debugging
docker exec wordpress bash -c \
  "echo \"define('WP_DEBUG', true);\" >> /var/www/html/wp-config.php"
```

### Common Issues and Solutions

#### 1. Container Won't Start

```bash
# Check logs
docker logs <container_name>

# Check if port is in use
sudo lsof -i :443
sudo lsof -i :3306

# Rebuild container
docker-compose build --no-cache <service_name>
docker-compose up -d <service_name>
```

#### 2. Database Connection Failed

```bash
# Check MariaDB is running
docker ps | grep mariadb

# Test database connection
docker exec mariadb mysqladmin ping -h localhost

# Check credentials
docker exec wordpress env | grep MYSQL

# Reset database
make fclean
make
```

#### 3. Permission Denied Errors

```bash
# Fix volume permissions
sudo chown -R www-data:www-data /home/$USER/data/wordpress
sudo chown -R mysql:mysql /home/$USER/data/mariadb

# Or inside container
docker exec wordpress chown -R www-data:www-data /var/www/html
docker exec mariadb chown -R mysql:mysql /var/lib/mysql
```

#### 4. SSL/TLS Certificate Issues

```bash
# Regenerate SSL certificate
docker exec nginx openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/CN=eamchart.42.fr"

# Restart Nginx
docker restart nginx
```

### Development Workflow

#### Making Changes

```bash
# 1. Stop services
make down

# 2. Edit configuration files
nano srcs/requirements/nginx/conf/nginx.conf

# 3. Rebuild specific service
docker-compose build nginx

# 4. Restart services
make up

# 5. Test changes
curl -k https://localhost
```

#### Hot Reloading (for development)

```yaml
# Add bind mount to docker-compose.yml
services:
  nginx:
    volumes:
      - ./requirements/nginx/conf:/etc/nginx:ro

# Changes to config files will be reflected immediately
# Just reload nginx:
docker exec nginx nginx -s reload
```

### Testing Commands

```bash
# Test Nginx configuration
docker exec nginx nginx -t

# Test PHP-FPM
docker exec wordpress php-fpm -t

# Test MariaDB connection
docker exec mariadb mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} ping

# Test WordPress CLI
docker exec wordpress wp --info --allow-root

# Test Redis
docker exec redis redis-cli ping

# Test network connectivity
docker exec wordpress ping -c 3 mariadb
docker exec wordpress ping -c 3 nginx
```

---

## 🏛️ Architecture Deep Dive

### Network Architecture

```yaml
networks:
  inception:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
```

**Network Details:**
- Type: Bridge network
- Subnet: 172.20.0.0/16
- DNS: Automatic service discovery by container name
- Isolation: Containers only communicate within this network

**Container IPs (example):**
```
nginx     → 172.20.0.2
wordpress → 172.20.0.3
mariadb   → 172.20.0.4
redis     → 172.20.0.5
```

### Service Dependencies

```yaml
services:
  mariadb:
    # No dependencies - starts first

  wordpress:
    depends_on:
      - mariadb
    # Starts after mariadb

  nginx:
    depends_on:
      - wordpress
    # Starts after wordpress
```

### Dockerfile Architecture

Each service follows this pattern:

```dockerfile
# 1. Base image
FROM debian:bullseye

# 2. Install packages
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# 3. Copy configuration
COPY conf/config.conf /etc/service/

# 4. Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# 5. Expose ports
EXPOSE 443

# 6. Set entrypoint
ENTRYPOINT ["entrypoint.sh"]
```

### Port Mapping

| Service | Internal Port | External Port | Protocol |
|---------|--------------|---------------|----------|
| Nginx | 443 | 443 | HTTPS |
| WordPress | 9000 | - | FastCGI |
| MariaDB | 3306 | - | MySQL |
| Redis | 6379 | - | Redis |
| Adminer | 8080 | 8080 | HTTP |
| FTP | 21, 20 | 21, 20 | FTP |
| Portainer | 9443 | 9443 | HTTPS |

### File Structure Overview

```
push_incept/
├── Makefile                    # Build automation
├── README.md                   # Project overview
├── USER_DOC.md                 # User documentation
├── DEV_DOC.md                  # This file
└── srcs/
    ├── .env                    # Environment variables (create this)
    ├── docker-compose.yml      # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile      # MariaDB image definition
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── mariadb.sh  # Initialization script
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── wordpress-php.sh
        └── bonus/              # Optional services
            ├── adminer/
            ├── ftp/
            ├── portainer/
            ├── redis/
            └── static/
```

---

<div align="center">

**For user instructions, see [USER_DOC.md](USER_DOC.md)**

Made with ❤️ by a 42 student

</div>