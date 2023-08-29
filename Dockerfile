ARG DEBIAN_VERSION=bullseye

FROM debian:${DEBIAN_VERSION}

ARG PHP_BUILD_VERSION=8.0
ENV PHP_VERSION=${PHP_BUILD_VERSION}

LABEL maintainer="UNC ClinGen Workflow Infrastructure Developers"

WORKDIR /srv/app

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates zip unzip nginx openssh-client \
    && . /etc/os-release \
    && curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends php${PHP_VERSION}-cli \
       php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-gd \
       php${PHP_VERSION}-curl php${PHP_VERSION}-rdkafka \
       php${PHP_VERSION}-imap php${PHP_VERSION}-opcache php${PHP_VERSION}-mysql \
       php${PHP_VERSION}-xml php${PHP_VERSION}-zip \
       php${PHP_VERSION}-readline php${PHP_VERSION}-pcov \
       php${PHP_VERSION}-redis php${PHP_VERSION}-xdebug \
       php${PHP_VERSION}-mbstring \
       php${PHP_VERSION}-fpm \
    && update-alternatives --set php /usr/bin/php${PHP_VERSION} \
    && curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i -e '/^error_log =/s|.*|error_log = /proc/self/fd/2|' /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
    && sed -i -e '/^pid =/s|.*|pid = /tmp/php-fpm.pid|' /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
    && rm /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
    && mkdir -p /var/log/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ADD php-fpm-app.conf /etc/php/${PHP_VERSION}/fpm/pool.d/app.conf
ADD nginx-default.conf /etc/nginx/conf.d/default.conf
ADD nginx-gzip.conf /etc/nginx/conf.d/nginx-gzip.conf
ADD nginx-upstream-fpm.conf /etc/nginx/conf.d/_upstream-fpm.conf
ADD nginx.conf /etc/nginx/nginx.conf
ADD README.md /image-README.md

RUN chmod -R g+w /etc/nginx && chmod -R g+w /etc/php

USER www-data:0

ENTRYPOINT ["bash"]
