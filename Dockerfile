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
    && apt-get install -y --no-install-recommends lsb-release ca-certificates curl ca-certificates zip unzip git \
       nginx openssh-client \
    && curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
    && sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' \
    && apt-get update \
    && apt-get install -y --no-install-recommends php${PHP_VERSION}-cli \
       php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-gd \
       php${PHP_VERSION}-curl php${PHP_VERSION}-rdkafka \
       php${PHP_VERSION}-imap php${PHP_VERSION}-opcache php${PHP_VERSION}-mysql \
       php${PHP_VERSION}-xml php${PHP_VERSION}-zip \
       php${PHP_VERSION}-readline php${PHP_VERSION}-pcov \
       php${PHP_VERSION}-redis php${PHP_VERSION}-xdebug \
       php${PHP_VERSION}-fpm \
    && update-alternatives --set php /usr/bin/php${PHP_VERSION} \
    && curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /srv/app

USER www-data:0

ENTRYPOINT ["bash"]
