**conf/nginx.conf**
```code
events {
    worker_connections 1024; # Max simultaneous connections per worker
}

http {
	server {
		listen 443 ssl;
		ssl_protocols TLSv1.2 TLSv1.3;

		ssl_certificate /etc/nginx/ssl/1337inception.crt;
		ssl_certificate_key /etc/nginx/ssl/1337inception.key;

		root /var/www/html;
		server_name localhost;
		index index.php index.html index.htm;

		location / {
			try_files $uri $uri/ =404;
		}

		location ~ \.php$ {						
			include snippets/fastcgi-php.conf;
			fastcgi_pass 127.0.0.1:9000;
		}
	}
}

```
`nginx -t` this command is to check if the syntax of the config file correct.

**Dockerfile**
```Dockerfile
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install nginx openssl -y && \
    mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -out /etc/nginx/ssl/1337inception.crt -keyout /etc/nginx/ssl/1337inception.key \
    -subj "/CN=eamchart.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
```
in the future to be able to access `eamchart.42.fr` you need to make it points to its local IP address (127.0.0.1) via:
```code
vi /etc/hosts

127.0.0.1   eamchart.42.fr
```
also in **conf/nginx.conf** change this `server_name localhost;` to `server_name eamchart.42.fr;`
- [ ] it will work with both we just changed it because that's the way it should be.
