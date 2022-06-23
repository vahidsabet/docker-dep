FROM alpine:latest

ENV CONFIG_PATH=config
#ENV NODE_VERSION=11.0.0

# Installing packages
RUN apk --no-cache add \
                   nginx \
                   php8 \
                   php8-common \ 
                   php8-cli \
                   php8-fpm \
                   php8-dom \ 
                   php8-gd \
                   php8-nbstring \
                   php8-xml \
                   php8-intl \
                   php8-curl \
                   php8-gmp \
                   php8-bcmath \
                   php8-pcntl \
                   php8-posix \
                   php8-zip \
                   php8-redis \
                   php8-phar \
                   php8-openssl \
                   php8-ctype \
                   php8-json \
                   php8-opcache \
                   php8-session \
                   php8-zlib \
                   php8-tokenizer \
                   php8-fileinfo \
                   wget \
                   unzip \
                   gcc \
                   bzip2 \
                   git \
                   openssl \
                   curl \
                   nano \
                   supervisor \ 
                   npm \ 
                   nodejs \ 
                   python3 \
                   python3-dev 

RUN npm install -g yarn node-gyp

# create symlink so programs on php would know
RUN ln -s /usr/bin/php8 /usr/bin/php

# Make directories
RUN mkdir -p /var/www/html

COPY ${CONFIG_PATH}/supervisord.conf /etc/supervisord.conf
COPY ${CONFIG_PATH}/nginx.conf /etc/nginx/nginx.conf
COPY ${CONFIG_PATH}/fpm-pool.conf /etc/php8/php-fpm.d/www.conf
COPY ${CONFIG_PATH}/php.ini /etc/php8/conf.d/custom.ini

# Entrypoint
COPY --chown=nginx ${CONFIG_PATH}/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set Premissions
RUN chown -R nginx /var/www/html && \
    chown -R nginx /run && \
    chown -R nginx /var/lib/nginx && \
    chown -R nginx /var/lob/nginx 

# Switch to use non-root user \
USER nginx

# Build the app
COPY --chown=nginx dashboard /var/www/dashboard
RUN npm --prefix /var/www/dashboard install
RUN npm --prefix /var/www/dashboard run build
RUN mv /var/www/dashboard/build/* /var/www/html

EXPOSE 8080
EXPOSE 8443

CMD [ "nginx","g","daemon off;" ]
#ENTRYPOINT [ "/entrpoint.sh" ]
#CMD [ "/usr/bit/supervisord","-n" ]
