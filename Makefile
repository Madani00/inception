COMPOSE = docker compose
COMPOSE_FILE = srcs/docker-compose.yml


all: build up

# build the docker images
build: setup
	$(COMPOSE) -f $(COMPOSE_FILE) build

# do not forget -d 
up:
	$(COMPOSE) -f $(COMPOSE_FILE) up

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

# you can use this 
restart: down up
# restart:
# 	$(COMPOSE) -f $(COMPOSE_FILE) restart

logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs

clean:
	$(COMPOSE) -f $(COMPOSE_FILE) down -v

fclean: clean
	docker system prune -af

# remove the persistent data (in your home folder)
fcleanall : fclean
	sudo rm -rf /home/eamchart/data/wordpress/* /home/eamchart/data/mariadb/*

re: fcleanall all

setup:
	@mkdir -p /home/eamchart/data/wordpress
	@mkdir -p /home/eamchart/data/mariadb

.PHONY: all build up down restart logs clean fclean fcleanall re setup
