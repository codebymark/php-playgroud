FROM php:7.4-apache
RUN apt-get update

RUN apt-get install -y \
        wget \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt-dev \
		libpng-dev \
		libxml2-dev \
		libzip-dev \
	&& docker-php-ext-install -j$(nproc) gd zip mysqli pdo pdo_mysql xml dom json


RUN cd /tmp \
        && wget https://xdebug.org/files/xdebug-3.1.0.tgz \
        && tar -zxvf xdebug-3.1.0.tgz \
        && cd xdebug-3.1.0 \
        && /usr/local/bin/phpize \
        && ./configure --enable-xdebug --with-php-config=/usr/local/bin/php-config \
        && make \
        && mkdir /usr/local/lib/php/extensions/xdebug/ \
        && cp modules/xdebug.so /usr/local/lib/php/extensions/xdebug/xdebug.so


RUN { \
            echo '[xdebug]'; \
            echo 'zend_extension=/usr/local/lib/php/extensions/xdebug/xdebug.so'; \
            echo 'xdebug.mode=debug'; \
            echo 'xdebug.idekey=PHPSTORM'; \
            echo 'xdebug.remote_autostart=on'; \
            echo 'xdebug.remote_connect_back=0'; \
            echo 'xdebug.remote_handler=dbgp'; \
            echo 'xdebug.profiler_enable_trigger=1'; \
            echo 'xdebug.profiler_output_dir="/var/www/html"'; \
            echo 'xdebug.remote_port=9000'; \
            echo 'xdebug.remote_host=host.docker.internal'; \
        } > /usr/local/etc/php/conf.d/xdebug.ini

#COPY ./config/php/xdebug.ini $PHP_INI_DIR/conf.d/
#RUN docker-php-ext-enable xdebug

COPY --from=composer /usr/bin/composer /usr/bin/composer

ENV APACHE_DOCUMENT_ROOT /var/www/html/

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

