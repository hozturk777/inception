include srcs/.env

COMPOSE		= docker compose -f srcs/docker-compose.yml
SECRETS		= secrets/db_root_password.txt \
			  secrets/db_password.txt \
			  secrets/credentials.txt

all: up

up: dirs check-secrets
	$(COMPOSE) up -d --build

dirs:
	mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

# Secrets are written by hand (see DEV_DOC.md); stop if one is missing or empty
check-secrets:
	@for f in $(SECRETS); do \
		[ -s "$$f" ] || { echo "Error: $$f is missing or empty (see DEV_DOC.md)" >&2; exit 1; }; \
	done

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

# Remove containers, images and Docker volumes (host data is kept)
clean:
	$(COMPOSE) down --rmi all -v

# Also delete the persistent data on the host (files are owned by container users)
fclean: clean
	sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all up dirs check-secrets down stop start ps logs clean fclean re
