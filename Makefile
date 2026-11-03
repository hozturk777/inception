include srcs/.env

COMPOSE		= docker compose -f srcs/docker-compose.yml
SECRETS_DIR	= secrets
SECRETS		= $(SECRETS_DIR)/db_root_password.txt \
			  $(SECRETS_DIR)/db_password.txt \
			  $(SECRETS_DIR)/credentials.txt

# Random alphanumeric password (no quotes/special chars to break SQL or shell)
GEN_PASS	= openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | cut -c1-20

all: up

up: dirs $(SECRETS)
	$(COMPOSE) up -d --build

dirs:
	mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

# Secrets are created only if missing, never overwritten
$(SECRETS_DIR)/db_root_password.txt $(SECRETS_DIR)/db_password.txt:
	@mkdir -p $(SECRETS_DIR)
	@$(GEN_PASS) > $@
	@chmod 600 $@
	@echo "Generated $@"

$(SECRETS_DIR)/credentials.txt:
	@mkdir -p $(SECRETS_DIR)
	@printf "WP_ADMIN_PASSWORD=%s\nWP_USER_PASSWORD=%s\n" "$$($(GEN_PASS))" "$$($(GEN_PASS))" > $@
	@chmod 600 $@
	@echo "Generated $@"

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

.PHONY: all up dirs down stop start ps logs clean fclean re
