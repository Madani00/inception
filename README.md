*This project has been created as part of the 42 curriculum by eamchart.*

<div align="center">

# 🐳 Inception - Docker Infrastructure Project

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Docker Compose](https://img.shields.io/badge/Docker_Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)

**A complete containerized web infrastructure featuring Nginx, WordPress, MariaDB, and more**


</div>


---
**For user instructions, see [USER_DOC.md](USER_DOC.md)**

## ✔️ Part 0: configs , dockerfiles ✔️
### 1.MariaDB
[check this link --> MariaDB](./srcs/requirements/mariadb/README.md)

### 2.Nginx
[check this link --> Nginx](./srcs/requirements/nginx/README.md)


### 3. WordPress
[check this link --> wordpress](./srcs/requirements/wordpress/README.md)







## ✔️ Part 1: Individual Basic Checks ✔️
Since we haven't created the Docker network & docker compose yet,
lets test all the 3 containers manually if everything is working fine.

### 1. Test MariaDB (The Engine)
since you didn't create `.env` file, we'll pass the environment variables manually to mariadb.
```bash
# Go to folder
cd ~/inception/srcs/requirements/mariadb

# Build the image
docker build -t mariadb-img .

# Run it (Manually passing variables)
docker run -d --name mariadb \
  -e MADANI_USER=madanidb \
  -e MADANI_PASSWORD=madani_password \
  -e MADANI_ROOT_PASSWORD=root_password \
  -e MADANI_DATABASE=madani_db mariadb-img


# Test connection as root
docker exec mariadb mysql -u root -p"root_password" -e "SELECT 1;"

# Test connection as the regular user
docker exec mariadb mysql -u madanidb -p"madani_password" -e "SELECT 1;"

# Verify database exists
docker exec mariadb mysql -u madanidb -p"madani_password" -e "SHOW DATABASES;"

```
if you do not encounter any errors with these command, you are good to go


### 2. Test NGINX (The Gatekeeper)

```bash
cd ~/inception/srcs/requirements/nginx

docker build -t nginx-img .

docker run --rm -it --name nginx -p 443:443 nginx-img
```
if you see it hangs (stays running) and doesn't exit. --> ✅ Success

> when you access nginx the homepage `https://localhost` you see and error page often means it is working
Why? Because your NGINX looks in `/var/www/html`, and that folder is currently empty.

now lets test manually a page, we will simple inject a file to that path so that you can see an actual page.
```bash
# this command will create an index.html manually inside the running container
docker exec nginx sh -c 'echo "<h1>Hello from Docker! NGINX is working.</h1>" > /var/www/html/index.html'
```

**Check the Browser**
1. Go to https://localhost (or https://madani.42.fr if you set up your hosts file).
2. Expect a Warning: You will see "Your connection is not private" (because of our self-signed certificate).
3. Bypass it: Click Advanced -> Proceed to... (unsafe).
4. Success: You should see "Hello from Docker! NGINX is working."



### 3. Test WordPress (The App)
This one might complain about missing DB, but PHP-FPM should still start.
```bash
cd ~/inception/srcs/requirements/wordpress

docker build -t wordpress-img .

docker run --rm -it wordpress-img
```
if you see something like :
> Success: WordPress downloaded.
> Error: Database connection error (2002).

all good, sure the connection will fail cause the mariadb container is not running 
(and not connected via a Docker Network), this step is supposed to fail.





## ✔️ Part 2: Advanced Checks NGINX & WORDPRESS & MariaDB ✔️

- since you don't have connection established between the nginx and php, so they cannot communicate.
so next we need to configure php, and we will make a small modifications to it.
the only thing that you need to change in this config is a line  usually at (36 line) `listen = /run/php/php7.4-fpm.sock` to :
```shell
# The address on which to accept FastCGI requests.
listen = wordpress:9000
```

**conf/www.conf**

```code
[www]

user = www-data
group = www-data

listen = 0.0.0.0:9000

pm = dynamic

pm.max_children = 5

pm.start_servers = 2

pm.min_spare_servers = 1

pm.max_spare_servers = 3
```

> (By default, PHP-FPM server listening on port 9000 that binds to 127.0.0.1 (localhost).)

⚠️ NOTE : make sure you change this line on nginx config to `fastcgi_pass wordpress:9000` ,wordpress is the name of your container keep that in mind.
now NGINX can send its work to PHP-FPM which waits in the background on Port 9000.

nginx and wordpress containers are in isolated rooms , we need to put them in the same room to test the connection.

### test NGINX & WORDPRESS
#### 🛠️ Step 1: Create a Manual Network 

```bash
docker network create test-net

```
#### 🛠️ Step 2: Create a Volume
NGINX cannot look inside the WordPress container's storage. that is why we need to create 
a shared storage space so NGINX can see the files WordPress downloads.

```bash
# create a volume
docker volume create manual-test-vol 
```

#### 🛠️ Step 3: Start WordPress

```bash
docker build -t wordpress-img .

docker run --rm -d --name wordpress  --network test-net -v manual-test-vol:/var/www/html \
  -e MADANI_DATABASE=madani_db -e MADANI_USER=madanidb \
  -e MADANI_PASSWORD=madani_password wordpress-img 

```

#### 🛠️ Step 4: Start NGINX

Now we start NGINX and attach it to the same network.
```bash
docker build -t nginx-img .
docker run --rm -d --name nginx --network test-net -v manual-test-vol:/var/www/html \
-p 443:443 nginx-img

```
both the containers should stay running so our test would be valid.


#### 🛠️ Step 5: test 
If you do this:
1. Go to https://localhost 
2. if you are lucky like me you are gonna see a page like this:
- [ ] (optional) if you want to see the CSS on this page, add this line to the file **nginx.conf**, you should place it inside the http block,
`include /etc/nginx/mime.types;`
![alt text](<.images/Screenshot from 2026-01-21 15-45-43.png>)
which means **Success**: NGINX served the page & PHP executed the code.
if you click submit you are gonna see this:
![alt text](<.images/Screenshot from 2026-01-17 13-43-32.png>)


This is perfect! It means NGINX found the file, sent it to PHP, and PHP ran.
WordPress needs a database to work, at least know its password, name and host.
All this is configured in the file `wp-config.php`, your job is to configure this file to make the setup automatic. that's why we added the following line in **wordpress-php.sh**
```yaml
wp-cli config create --dbname=$MADANI_DATABASE \
--dbuser=$MADANI_USER --dbpass=$MADANI_PASSWORD \
--dbhost=mariadb:3306 --allow-root 
```

### test MariaDB & WORDPRESS & Nginx

first of all before testing all togother, let's first clean everything
#### 🧹 Step 1: Clean

```zsh
# Stop and remove containers
docker stop nginx wordpress mariadb
docker rm nginx wordpress mariadb

# Remove the volume & Volume 
docker volume rm manual-test-vol
docker network rm test-net

```

#### 🛠️ Step 2: Start all

```bash

# Re-create Network and Volume
docker network create test-net
docker volume create manual-test-vol

# again create the images
docker build -t mariadb-img .
docker build -t wordpress-img .
docker build -t nginx-img .

# now run the cotainers
docker run --rm -d --name mariadb --network test-net  \
-e MADANI_USER=madanidb -e MADANI_PASSWORD=madani_password \
-e MADANI_ROOT_PASSWORD=root_password -e MADANI_DATABASE=madani_db mariadb-img

docker run --rm -d --name wordpress  --network test-net -v manual-test-vol:/var/www/html \
-e MADANI_DATABASE=madani_db -e MADANI_USER=madanidb \
-e MADANI_PASSWORD=madani_password wordpress-img 

docker run --rm -d --name nginx --network test-net -v manual-test-vol:/var/www/html \
-p 443:443 nginx-img

```
if all goes well you are gonna see this:
![alt text](<.images/Screenshot from 2026-01-18 16-58-31.png>)

now uncomment the line at (line 32 in **wordpress-php.sh**) so we can Install WordPress with site details automatically, now test again.

```bash
# create the images again cause we changed the script
docker build -t wordpress-img .

# run now the container with the new variables we added
docker run --rm -d --name wordpress  --network test-net -v manual-test-vol:/var/www/html \
-e MADANI_DATABASE=madani_db -e MADANI_USER=madanidb \
-e MADANI_PASSWORD=madani_password -e MADANI_WP_ADMIN_USER=daniel \
-e MADANI_WP_ADMIN_PASSWORD=daniel_password -e MADANI_WP_ADMIN_EMAIL=daniel@gmail.com \
wordpress-img 
```
if all goas well you are gonna see this page
![alt text](<.images/Screenshot from 2026-01-18 17-12-17.png>)

---

## docker compose
create the docker compose
```docker-compose
services:
  mariadb:
    build: requirements/mariadb/.
    container_name: mariadb
    env_file: .env
    networks:
      - 42network
    volumes:
      - mariadb_data:/var/lib/mysql
  wordpress:
    build: requirements/wordpress/.
    container_name: wordpress
    depends_on:
      - mariadb
    env_file: .env
    networks:
      - 42network
    volumes:
      - wordpress_data:/var/www/html
  nginx:
    build: requirements/nginx/.
    container_name: nginx
    ports:
      - "443:443"
    depends_on:
      - wordpress
    networks:
      - 42network
    volumes:
      - wordpress_data:/var/www/html

volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/eamchart/data/wordpress
  
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/eamchart/data/mariadb

networks:
  42network:
    driver: bridge
```

Next steps: create the host directories if they don’t exist (/home/madani/data/wordpress and /home/madani/data/mariadb), then docker compose down && docker compose up --build. Double-check your .env values for the database and WordPress credentials.



1. Fill `.env` with all required vars: `MADANI_ROOT_PASSWORD`, `MADANI_USER`, `MADANI_PASSWORD` ...


2. Then docker compose down && Reset the bind-mounted data
```bash

docker compose down -v
rm -rf /home/eamchart/data/mariadb/* /home/eamchart/data/wordpress/*
docker compose up --build

docker compose down 
docker compose up
```
The `-v` flag removes volumes, and `--build` forces image rebuild

3. debug maridb
```bash
docker compose -f 'srcs/docker-compose.yml' up 'mariadb'
rm -rf /home/eamchart/data/mariadb/* /home/eamchart/data/wordpress/*
```

### add users
the subject told us to create 2 users we previously create the admin now it's time to the other other. to do so lets add the following to wordpress script:
```bash
# Create a new WordPress user.
	wp-cli user create "$NEW_WP_USER" "$NEW_WP_USER_EMAIL" \
						--user_pass="$NEW_WP_USER_PASSWORD" \
						--role="author" \
						--allow-root
```
now lets test the users on the browser.
#### 🖥️ Method 1: The Browser Test


1. Go to https://eamchart.42.fr/wp-login.php.
2. Test the Administrator (The Boss)
    - Log in as your admin
    - Look at the black menu on the left.
    - Do you see the word "Plugins" or "Settings"?
        - YES: ✅ Good. This user has "God Mode." They can change the website's brain.

3. Test the Second User (The Employee)
    - Log out of the admin account.
    - Log in as your second user
    - Look at the black menu on the left.
    - The Key Check: Do you see the word "Plugins" or "Settings"?
        - NO: ✅ PERFECT. This user is locked out of the dangerous stuff.


#### 💽 5. MariaDB & Persistence test
- The "Delete" Test:
  1. Create a post in WordPress.
  2. Run docker compose down and Run docker compose up -d.
  3. Is the post still there? (It must be there).







### final touch (fix errors)

1. 

The socket error happens because the script tries to connect before MariaDB is fully ready. We need to wait for the socket file to exist and MySQL to be listening.

`**mariadb | ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/run/mysqld/mysqld.sock' (111)**`

to fix this you can eather add a condition to wait for Mariadb to be ready in wordpress script or you can tell Docker Compose to monitor MariaDB's health with `healthcheck`
---

2. 
the mariaDB volume `/home/eamchart/data/..` should have the user `eamchart` premission so you can write and read from it
```yaml
# Fix ownership of the home
sudo chown -R eamchart:eamchart /home/eamchart/data
```
---

3. 
![alt text](<.images/Screenshot from 2026-01-22 11-48-47.png>)

i added a condition in both script of mariadb & wordpress to check if the wordpress if already exists, also the same thing for the MariaDB check if it is already initialized before running the setup commands



## some best practices
- in the configuration file of wordpress we changed:
```bash
# CRITICAL: listen on port 9000 on all interfaces
listen = 0.0.0.0:9000
```
to
```bash
# to listen on port 9000 of the wordpress hostname
listen = wordpress:9000
```

- EXPOSE THE port inside the cotainer so other container can see it
- add in docker compose `start: always` in case one of cotainer fails it starts again
- Layer Optimization (small images): you should always combine commands that are logically related into a single RUN instruction. This follows the Principle of Least Privilege for Disk Space.

```docker
RUN apt-get update && apt-get install -y \
    wget \
    php7.3 \
    && rm -rf /var/lib/apt/lists/*
```
(`rm -rf`) deletes the temporary package lists, making your container even smaller.
- use `secrets` for sensitive passwords instead of using `.env`

## some usefull commands
```bash
# Check logs
# When a container exits immediately, it usually "screamed" an error message, check it with
docker logs test-db

# to copy the config file from the container to your host, (wordpress is container name)
docker cp wordpress:/etc/php/7.4/fpm/pool.d/www.conf .

# to remove all the stopped containers
docker container prune

# clean up all unused containers, images & networks
docker system prune

# build an image completely from scratch without using any cache
docker build --no-cache -t your-image-name .

# Test HTTP to HTTPS redirect
curl -I http://eamchart.42.fr
curl -k -I https://eamchart.42.fr

# to list processes running inside of each service (container).
docker-compose top 

```

