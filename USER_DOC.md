# User documentation

## Services provided

| Service     | What it does                                                        |
|-------------|---------------------------------------------------------------------|
| `nginx`     | Web server; the only way in, over HTTPS (port 443, TLSv1.2/1.3)      |
| `wordpress` | The WordPress website, executed by php-fpm                           |
| `mariadb`   | Database storing posts, users and settings                           |

## Start and stop

Run these commands from the root of the repository:

| Command      | Effect                                                         |
|--------------|----------------------------------------------------------------|
| `make`       | Build images (if needed) and start all services                 |
| `make stop`  | Stop the containers (they can be resumed with `make start`)     |
| `make start` | Start stopped containers again                                 |
| `make down`  | Stop and remove the containers (data is kept)                   |

## Access the website

The domain `huozturk.42.fr` must point to the machine (once):

```sh
echo "127.0.0.1 huozturk.42.fr" | sudo tee -a /etc/hosts
```

- Website: https://huozturk.42.fr
- Administration panel: https://huozturk.42.fr/wp-admin

The certificate is self-signed, so the browser shows a warning the first time;
accept it to continue. Plain `http://` (port 80) is intentionally not available.

## Credentials

| What                       | Where                                         |
|----------------------------|-----------------------------------------------|
| WordPress admin user name  | `WP_ADMIN_USER` in `srcs/.env`                 |
| WordPress second user name | `WP_USER` in `srcs/.env` (role: author)        |
| WordPress passwords        | `secrets/credentials.txt`                      |
| Database user password     | `secrets/db_password.txt`                      |
| Database root password     | `secrets/db_root_password.txt`                 |

```sh
cat secrets/credentials.txt
```

The `secrets/` folder is created by hand before the first `make` (see
[DEV_DOC.md](DEV_DOC.md)) and is never committed to git. Passwords are applied only when the site is first installed;
to change one afterwards, change it in the WordPress admin panel (Users → Profile), or
reset everything with `make fclean && make` (this deletes all site data).

## Check that services are running

```sh
make ps                                     # all three should be "Up", mariadb "healthy"
make logs                                   # live logs of every service (Ctrl+C to quit)
curl -kI https://huozturk.42.fr             # expect an HTTP 200/302 answer
curl -kI --tlsv1.1 --tls-max 1.1 https://huozturk.42.fr   # must FAIL (old TLS refused)
```
