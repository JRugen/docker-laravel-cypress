FROM php:8.2-alpine3.17

LABEL maintainer="John Rugen"
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/


ENV DEBIAN_FRONTEND=noninteractive 
ENV TERM xterm 
ENV npm_config_loglevel warn
ENV npm_config_unsafe_perm true
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null
ENV CHROME_VERSION 90.0.4430.212
ENV FIREFOX_VERSION 88.0.1
ENV CI=1
ENV CYPRESS_CACHE_FOLDER=/root/.cache/Cypress


# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    freetype-dev \
    g++ \
    gcc \
    git \
    icu-dev \
    icu-libs \
    libc-dev \
    libzip-dev \
    make \
    mysql-client \
    nodejs \
    npm \
    oniguruma-dev \
    yarn \
    openssh-client \
    postgresql-libs \
    rsync \
    zlib-dev


RUN apk add \
    # Cypress dependencies
    libnotify-dev \
    xauth \
    xvfb \
    # Extra dependencies
    mplayer \ 
    wget

# Install php extensions
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions \
    @composer \
    redis-stable \
    imagick-stable \
    xdebug-stable \
    bcmath \
    calendar \
    exif \
    gd \
    intl \
    pdo_mysql \
    pdo_pgsql \
    pcntl \
    soap \
    zip


# Cypress Browsers

# Chrome
RUN wget -O /usr/src/google-chrome-stable_current_amd64.deb "http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb" && \
    dpkg -i /usr/src/google-chrome-stable_current_amd64.deb ; \
   #apt-get install -f -y && \
    rm -f /usr/src/google-chrome-stable_current_amd64.deb

# Firefox
RUN wget --no-verbose -O /tmp/firefox.tar.bz2 "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2" \
    && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
    && rm /tmp/firefox.tar.bz2 \
    && ln -fs /opt/firefox/firefox /usr/bin/firefox

# Add local and global vendor bin to PATH.
ENV PATH ./vendor/bin:/composer/vendor/bin:/root/.composer/vendor/bin:/usr/local/bin:$PATH

# Install PHP_CodeSniffer
RUN composer global require "squizlabs/php_codesniffer=*"

# Setup working directory
WORKDIR /var/www

RUN echo 'test echo!'