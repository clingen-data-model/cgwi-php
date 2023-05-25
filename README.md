# Base PHP images [ClinGen](clinicalgenome.org) Workflow Infrastructure projects

These PHP images are intended to include some necessary extensions used by apps developed by this team,
and also to enable running as a non-root user (e.g., to be compatible with run in OpenShift).

[deb.sury.org](https://deb.sury.org) is used for packages for PHP and PHP extensions.

Images are auto-generated on push to main (and with semver tags) and have images names like
`cgwi-php-${DEBIAN_VERSION}-${PHP_VERSION}`