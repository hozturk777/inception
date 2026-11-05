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

clean:
	$(COMPOSE) down --rmi all -v

fclean: clean
	sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all up dirs check-secrets down stop start ps logs clean fclean re
