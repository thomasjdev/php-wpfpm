FROM php:7.4-fpm

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libzip-dev \
	; \
	\
	docker-php-ext-configure gd -with-freetype --with-jpeg; \
	docker-php-ext-install \
		bcmath \
		exif \
		gd \
		mysqli \
		opcache \
		zip \
	; \
	pecl install imagick; \
	docker-php-ext-enable imagick; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
# https://codex.wordpress.org/Editing_wp-config.php#Configure_Error_Logging
RUN { \
		echo 'error_reporting = 4339'; \
		echo 'display_errors = Off'; \
		echo 'display_startup_errors = Off'; \
		echo 'log_errors = On'; \
		echo 'error_log = /dev/stderr'; \
		echo 'log_errors_max_len = 1024'; \
		echo 'ignore_repeated_errors = On'; \
		echo 'ignore_repeated_source = Off'; \
		echo 'html_errors = Off'; \
	} > /usr/local/etc/php/conf.d/error-logging.ini

VOLUME /var/www/html