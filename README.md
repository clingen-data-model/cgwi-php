# Base PHP images [ClinGen](clinicalgenome.org) Workflow Infrastructure projects

These PHP images are intended to include some necessary extensions used by apps developed by this team,
and also to enable running as a non-root user (e.g., to be compatible with run in OpenShift).

[deb.sury.org](https://deb.sury.org) is used for packages for PHP and PHP extensions.

Images are auto-generated on push to main (and with semver tags) and have images names like
`cgwi-php-${DEBIAN_VERSION}-${PHP_VERSION}`

# How to use

These are intended to be used as part of a combined image with PHP code (e.g., something based on
the Laravel framework), available in the `/srv/app` directory. The image contains both nginx and php-fpm
packages, so it's possible to run both from the same image (although typically in different containers).
By default (defined in `/etc/nginx/conf.d/default.conf`), nginx will look to `app:9000` as the upstream
for PHP-FPM. You might need to change that (e.g., to a socket) if nginx and the app are run in the same
host/pod, or if you are in a namespace with more than one fpm backend (like a dev and prod). The easiest
way to do this is probably by overlay on `_upstream-fpm.conf`

If you're running using docker-compose or kubernetes, you can use an entrypoint like
`php-fpm${PHP_VERSION} -F -O` to run the php-fpm pool and one like
`/usr/sbin/nginx -g "daemon off;"` run the nginx process.
