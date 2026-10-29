# Base PHP images [ClinGen](clinicalgenome.org) Workflow Infrastructure projects

These PHP images are intended to include some necessary extensions used by apps developed by this team,
and also to enable running as a non-root user (e.g., to be compatible with run in OpenShift).

[deb.sury.org](https://deb.sury.org) is used for packages for PHP and PHP extensions.

Images are auto-generated on push to main (and with semver tags) and have images names like
`cgwi-php-${DEBIAN_VERSION}-${PHP_VERSION}`

# How to use

These are intended to be used as part of a combined image with PHP code (e.g., something based on
the Laravel framework), available in the `/srv/app` directory. The image runs php-fpm, listening on
port 9000 (pool config in `/etc/php/${PHP_VERSION}/fpm/pool.d/app.conf`).

To serve HTTP, run the official [caddy](https://hub.docker.com/_/caddy) image as a separate container
with the app's `public` directory mounted at `/srv/app/public` and a `Caddyfile` along these lines:

```
:8080 {
	root * /srv/app/public
	encode zstd gzip
	request_body {
		max_size 16MB
	}
	php_fastcgi app:9000 {
		read_timeout 180s
	}
	file_server
}
```

Change `app:9000` to wherever php-fpm is reachable (e.g., `localhost:9000` when both run in the same pod).

If you're running using docker-compose or kubernetes, you can use an entrypoint like
`php-fpm${PHP_VERSION} -F -O` to run the php-fpm pool.
