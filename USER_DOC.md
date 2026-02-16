*This project has been created as part of the 42 curriculum by eamchart.*

<div align="center">

# 📘 Inception - User Documentation

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)

**Complete guide for end users and administrators**

</div>


---

## 📋 Table of Contents

- [📖 Description](#-description)
- [📦 Prerequisites](#-prerequisites)
- [💻 Usage](#-usage)
- [📁 Project Structure](#-project-structure)
- [⚙️ Configuration](#️-configuration)
- [🔒 Security](#-security)
- [🧪 Testing](#-testing)
- [📊 Makefile Commands](#-makefile-commands)



---

## 📖 Description

Inception is a **42 School project** that challenges students to build a complete web infrastructure using **Docker** and **Docker Compose**. The project focuses on understanding containerization, orchestration, networking, and system administration best practices.

### 🎯 Project Goals

✅ Set up a multi-container Docker application  
✅ Configure a secure NGINX web server with TLS  
✅ Deploy WordPress with PHP-FPM  
✅ Set up MariaDB database  
✅ Implement proper networking and volumes  
✅ Follow Docker and security best practices  
✅ (Bonus) Add Redis, Adminer, FTP, Portainer, and static site  

### 🌐 Project Overview

- **Core services**: Nginx, WordPress (PHP-FPM), MariaDB
- **Bonus services**: Adminer, FTP (vsftpd), Portainer, Redis, Static Site
- **Infrastructure**: Custom Dockerfiles, service configs, startup scripts, volumes, and networks

---


### 🌐 Services

| Service | Purpose | Port |
|---------|---------|------|
| **Nginx** | Reverse proxy & web server | 443 (HTTPS) |
| **WordPress** | Content management system | 9000 (PHP-FPM) |
| **MariaDB** | Relational database | 3306 (internal) |
| **Redis** | Caching layer | 6379 (internal) |
| **Adminer** | Database management UI | 8080 |
| **FTP** | File transfer | 21 |
| **Portainer** | Container management | 9443 |

---



### 🔄 Request Flow

```
1. User Browser
   ↓
2. HTTPS Request (Port 443)
   ↓
3. Nginx Container
   ├─ SSL/TLS Termination
   ├─ Static Files → Serve directly
   └─ PHP Files → Forward to WordPress
      ↓
4. WordPress Container (PHP-FPM)
   ├─ Process PHP
   ├─ Query Database
   └─ Generate Response
      ↓
5. MariaDB Container
   ├─ Execute SQL
   └─ Return Data
      ↓
6. Response → Nginx → User Browser
```


---

## 📦 Prerequisites

### Required Software


### 1️⃣ Clone the Repository

```bash
https://github.com/Madani00/inception.git
cd inception
```

### 2️⃣ Configure Environment

This project uses **Docker secrets** for sensitive data and a `.env` file for non-sensitive variables.

#### Step 1: Create the `.env` file

```bash
# Create .env file in srcs/ directory
cd srcs/
nano .env
```

**Environment variables in `.env`:**

```env
# Domain
DOMAIN_NAME=https://eamchart.42.fr

WP_TITLE=Inception

INCEPTION_FTP_USER=
INCEPTION_FTP_PASSWORD=
FTP_PASV_ADDRESS=10.0.2.15
```

#### Step 2: Create the secrets directory

```bash
# Create secrets directory in the root
mkdir -p secrets
cd secrets
```

**Create individual secret files:**

```bash
# Database secrets
echo "wordpress" > db_database.txt
echo "wpuser" > db_user.txt
echo "your_secure_db_password" > db_password.txt
echo "your_secure_root_password" > db_root_password.txt

# WordPress admin secrets
echo "admin" > wp_admin_user.txt
echo "secure_admin_password" > wp_admin_password.txt
echo "admin@example.com" > wp_admin_email.txt

# WordPress user secrets
echo "user" > wp_user.txt
echo "user_password" > wp_user_password.txt
echo "user@example.com" > wp_user_email.txt
```


All secret files should be in the `secrets/` directory at the root level.

### 3️⃣ Configure Hosts File

```bash
# Add domain to /etc/hosts
sudo nano /etc/hosts

# Add this line:
127.0.0.1 eamchart.42.fr
```

### 4️⃣ Create Data Directories

```bash
# Create volume directories
sudo mkdir -p /home/$USER/data/wordpress
sudo mkdir -p /home/$USER/data/mariadb

# Set permissions
sudo chown -R $USER:$USER /home/$USER/data/
```

---

## 💻 Usage

### Starting the Infrastructure

```bash
# Build images and start all containers
make

# Start all services
make up

# Stop all services
make down
```



### Accessing Services

- 🌐 **WordPress Site**: [https://eamchart.42.fr](https://eamchart.42.fr)
- 🔐 **WordPress Admin**: [https://eamchart.42.fr/wp-admin](https://eamchart.42.fr/wp-admin)
- 📊 **Adminer** (bonus): [http://localhost:8080](http://localhost:8080) or [https://eamchart.42.fr/adminer](https://eamchart.42.fr/adminer)
- 🐳 **Portainer** (bonus): [https://localhost:9443](https://localhost:9443) or [https://eamchart.42.fr/portainer](https://eamchart.42.fr/portainer)
- 💻 **Static website** (bonus): [https://localhost:8081](http://localhost:8081) or [https://eamchart.42.fr/static](https://eamchart.42.fr/static)


---

## 📁 Project Structure

```
inception/
├── secrets                          # contains secrets
├── Makefile                          # Build automation
├── README.md                         # This file
├── DEV_DOC.md                        # Developer documentation
├── USER_DOC.md                       # User documentation
└── srcs/
    ├── .env                          # Environment variables
    ├── docker-compose.yml            # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile            # MariaDB image
        │   ├── conf/
        │   │   └── 50-server.cnf     # MariaDB configuration
        │   └── tools/
        │       └── mariadb.sh        # Database initialization
        ├── nginx/
        │   ├── Dockerfile            # Nginx image
        │   └── conf/
        │       └── nginx.conf        # Nginx configuration
        ├── wordpress/
        │   ├── Dockerfile            # WordPress image
        │   ├── conf/
        │   │   └── www.conf          # PHP-FPM configuration
        │   └── tools/
        │       └── wordpress-php.sh  # WordPress setup script
        └── bonus/                    # Bonus services
            ├── adminer/
            ├── ftp/
            ├── portainer/
            ├── redis/
            └── static/
```

---

## ⚙️ Configuration

### 🌐 Nginx Configuration

- **TLS Version**: 1.2 and 1.3 only
- **Port**: 443 (HTTPS only)
- **PHP Handler**: FastCGI to WordPress container
- **SSL Certificate**: Self-signed (auto-generated)

### 📝 WordPress Configuration

- **PHP Version**: 7.4+
- **Process Manager**: PHP-FPM
- **Database**: MariaDB connection
- **Users**: 2 (Admin + Regular)
- **Caching**: Redis integration

### 🗄️ MariaDB Configuration

- **Engine**: InnoDB
- **Charset**: utf8mb4
- **Collation**: utf8mb4_unicode_ci
- **Port**: 3306 (internal only)

---

## 🔒 Security

### Best Practices Implemented

✅ **No root processes** - All services run as non-root users  
✅ **TLS encryption** - HTTPS only, no HTTP  
✅ **Isolated networks** - Containers on dedicated network  
✅ **No hardcoded secrets** - All credentials in `.env`  
✅ **Minimal base images** - Debian Bullseye slim  
✅ **No unnecessary packages** - Security through minimalism  
✅ **Volume permissions** - Proper ownership (`www-data`, `mysql`)  

### Security Recommendations

⚠️ Change default passwords in production  
⚠️ Use proper SSL certificates (not self-signed)  
⚠️ Enable firewall rules  
⚠️ Regular updates and patches  
⚠️ Implement backup strategy  

---

## 🧪 Testing

### Health Checks

```bash
# Nginx
docker exec nginx nginx -t

# PHP-FPM
docker exec wordpress php-fpm -t

# MariaDB
docker exec mariadb mysqladmin ping -h localhost

# Redis
docker exec redis redis-cli ping
```

---

## 📊 Makefile Commands

| Command | Description |
|---------|-------------|
| `make` | Build and start all containers |
| `make up` | Start all containers |
| `make down` | Stop all containers |
| `make restart` | Restart all containers |
| `make build` | Build all images |
| `make clean` | Stop and remove containers |
| `make fclean` | Complete cleanup (containers + volumes) |
| `make fcleanall` | Nuclear cleanup (everything) |
| `make re` | Complete rebuild |
| `make logs` | Show all logs |



---

<div align="center">

## 👤 Author

**eamchart**

Made with ❤️ by a 42 student

---


</div>
