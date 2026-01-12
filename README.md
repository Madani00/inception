<!-- 🛡️ Best Practice: PHP-FPM

Since we are using NGINX (not Apache), we cannot use standard PHP. NGINX is just a mailman; it doesn't know how to read PHP letters. It needs a translator.

    PHP-FPM (FastCGI Process Manager) is that translator.

    NGINX sends the request -> PHP-FPM executes the code -> PHP-FPM sends HTML back to NGINX.

## 🐛 Troubleshooting


## resources 



### A “Description” 
section that clearly presents the project, including its goal and a brief overview.

### An “Instructions” 
section containing any relevant information about compilation,
installation, and/or execution.

- how to install wordpress
https://developer.wordpress.org/advanced-administration/before-install/howto-install/
- php / Install WP-CLI
https://spinupwp.com/hosting-wordpress-yourself-nginx-php-mysql/
- debian image from docker hub
https://hub.docker.com/_/debian
- mariadb why run as root is good practice
https://mariadb.com/docs/server/security/securing-mariadb/running-mariadbd-as-root



### A “Resources” 
section listing classic references related to the topic (documen-
tation, articles, tutorials, etc.), as well as a description of how AI was used —
specifying for which tasks and which parts of the project. -->



# 🧪 Part 1: Individual Checks
Since we haven't created the Docker network & docker compose yet,
lets test all the 3 containers manually if everything is working fine.

## 1. Test MariaDB (The Engine)
since you didn't create `.env` file, we'll pass the environment variables manually to mariadb.
```bash
# Go to folder
cd ~/inception/srcs/requirements/mariadb

# Build the image
docker build -t test-mariadb .

# Run it (Manually passing variables)
docker run -d --name test-db \
  -e MADANI_USER=madanidb \
  -e MADANI_PASSWORD=madani_password \
  -e MADANI_ROOT_PASSWORD=root_password \
  -e MADANI_DATABASE=madani_db mariadb

# Check logs
docker logs test-db

# Test connection as root
docker exec test-db mysql -u root -p"root_password" -e "SELECT 1;"

# Test connection as the regular user
docker exec test-db mysql -u madanidb -p"madani_password" -e "SELECT 1;"

# Verify database exists
docker exec test-db mysql -u madanidb -p"madani_password" -e "SHOW DATABASES;"

```
if you do not encounter any errors with these command, you are good to go

## 2. Test WordPress (The App)
This one might complain about missing DB, but PHP-FPM should still start.
```bash
cd ~/inception/srcs/requirements/wordpress

docker build -t test-wordpress .

docker run --rm -it test-wordpress
```
if you see something like :
> Success: WordPress downloaded.
> Error: Database connection error (2002).

it means wordpress --> Builds, downloads WP, and tries to connect.
all good for now. sure the connection will fail cause the mariadb container is not running 
(and not connected via a Docker Network), this step is supposed to fail.

## 3. Test NGINX (The Gatekeeper)

```bash
cd ~/inception/srcs/requirements/nginx

docker build -t test-nginx .

docker run --rm -it -p 443:443 test-nginx
```
if you see it hangs (stays running) and doesn't exit. Success

- when you access nginx the homepage `https://localhost` you see and error page oftem means it is working
Why? Because your NGINX looks in `/var/www/html`, and that folder is currently empty.

now lets test manually a page, we will simple inject a file to that path so that you can see an actual page.
```bash
docker run --rm -d -p 443:443 --name debug-nginx test-nginx
# this command will create an index.html manually inside the running container
docker exec debug-nginx sh -c 'echo "<h1>Hello from Docker! NGINX is working.</h1>" > /var/www/html/index.html'
```

**Check the Browser**

1. Go to https://localhost (or https://madani.42.fr if you set up your hosts file).
2. Expect a Warning: You will see "Your connection is not private" (because of our self-signed certificate).
3. Bypass it: Click Advanced -> Proceed to... (unsafe).
4. Success: You should see "Hello from Docker! NGINX is working."

