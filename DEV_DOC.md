# Developer documentation

## Set up the environment from scratch

### Prerequisites (inside the VM)

- Debian/Ubuntu VM with `sudo`
- Docker Engine and the Docker Compose plugin (`docker compose version`)
- `make`
- Your user in the `docker` group: `sudo usermod -aG docker $USER` (then log in again)

### Configuration files

- `srcs/.env` — non-secret settings, read by Compose and by the Makefile:

  | Variable          | Meaning                                                   |
  |-------------------|-----------------------------------------------------------|
  | `LOGIN`           | 42 login                                                  |
  | `DOMAIN_NAME`     | `<login>.42.fr`                                           |
  | `DATA_PATH`       | Host folder for persistent data (`/home/<login>/data`)    |
  | `MYSQL_DATABASE`  | WordPress database name                                    |
  | `MYSQL_USER`      | Database user used by WordPress                            |
  | `WP_TITLE`        | Site title                                                |
  | `WP_ADMIN_USER`   | Administrator (must not contain `admin`)                   |
  | `WP_ADMIN_EMAIL`  | Administrator e-mail                                       |
  | `WP_USER`         | Second, non-admin user (role: author)                      |
  | `WP_USER_EMAIL`   | Second user e-mail (must differ from the admin's)           |

### Secrets

Stored in `secrets/` at the repository root (git-ignored). These files are not
generated: create them by hand before the first `make`. `make` stops with an error if
one of them is missing or empty.

```
secrets/db_root_password.txt   # one line: MariaDB root password
secrets/db_password.txt        # one line: password of MYSQL_USER
secrets/credentials.txt        # WP_ADMIN_PASSWORD=...
                               # WP_USER_PASSWORD=...
```

Avoid quotes and backslashes in passwords. Compose mounts each secret read-only at
`/run/secrets/<name>` only in the services that list it.

### Domain

```sh
echo "127.0.0.1 huozturk.42.fr" | sudo tee -a /etc/hosts
```

## Build and launch

```sh
make            # = make up: create data folders, check secrets, then
                #   docker compose -f srcs/docker-compose.yml up -d --build
make re         # full rebuild from zero (deletes data)
```

Startup order: `mariadb` starts and initializes the database on an empty volume →
its healthcheck becomes healthy → `wordpress` downloads/configures/installs WordPress
with WP-CLI if needed → `nginx` generates its certificate and serves on 443.

## Managing containers and volumes

| Make target   | Docker command                                          |
|---------------|---------------------------------------------------------|
| `make ps`     | `docker compose -f srcs/docker-compose.yml ps`          |
| `make logs`   | `... logs -f`                                           |
| `make stop`   | `... stop`                                              |
| `make start`  | `... start`                                             |
| `make down`   | `... down` (containers + network removed, data kept)     |
| `make clean`  | `... down --rmi all -v` (also images and volumes)        |
| `make fclean` | `clean` + `sudo rm -rf /home/huozturk/data`              |

Useful commands:

```sh
docker exec -it mariadb mariadb -u root -p          # SQL shell (root password secret)
docker exec -it wordpress wp user list --allow-root # WordPress users
docker exec -it nginx nginx -t                      # check nginx config
docker volume ls                                    # mariadb_data, wordpress_data
docker volume inspect mariadb_data                  # shows device=/home/huozturk/data/mariadb
docker network inspect inception
```

## Where data is stored and how it persists

| Volume           | Mounted at (container)                   | Host folder                     |
|------------------|------------------------------------------|---------------------------------|
| `mariadb_data`   | `/var/lib/mysql` (mariadb)                | `/home/huozturk/data/mariadb`   |
| `wordpress_data` | `/var/www/html` (wordpress, nginx `:ro`)  | `/home/huozturk/data/wordpress` |

Both are Docker **named volumes** (local driver, `driver_opts` pointing to the host
folder). The data survives `make down`, `make stop`, container crashes and VM reboots.
The entrypoints detect existing data and skip initialization. Only `make fclean`
deletes it.
