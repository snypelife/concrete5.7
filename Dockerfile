FROM snypelife/apache-php
LABEL maintainer="brettmrogerson@gmail.com"

# This image provides Concrete5.7 at root of site

# Add Let’s Encrypt Client respository so we can have TLS
RUN sudo add-apt-repository ppa:certbot/certbot

# Install pre-requisites for Concrete5 & nano for editing conf files
RUN apt-get update && \
      DEBIAN_FRONTEND=noninteractive apt-get -y install \
      php7.0-curl \
      php7.0-gd \
      php7.0-mysql \
      unzip \
      wget \
      patch \
      vim && \
      python-certbot-apache && \
      apt-get clean && rm -r /var/lib/apt/lists/*
    
# Find latest download details at https://www.concrete5.org/get-started
# - for newer version: change Concrete5 version# & download url & md5
ENV CONCRETE5_VERSION 5.7.5.2
ENV C5_URL https://www.concrete5.org/download_file/-/view/82243/
ENV C5_MD5 61e48a8d4bf281a25420c3d2186a1a3d
# nano and other commands will not work without this
ENV TERM xterm

# Copy apache2 conf dir & Download Concrete5
# Perl script to enable ability to activate 'Pretty URLs' and redirection in .htaccess by 'AllowOverride'
# - it matches a multi-line string and replaces 'None' with 'FileInfo'
RUN perl -i.bak -0pe 's/<Directory \/var\/www\/>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride None/<Directory \/var\/www\/>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride FileInfo/' /etc/apache2/apache2.conf && \
    cp -r /etc/apache2 /usr/local/etc/apache2 && \
    cd /usr/local/src && \ 
    wget --no-verbose $C5_URL -O concrete5.zip && \
    echo "$C5_MD5 concrete5.zip" | md5sum -c - && \
    unzip -qq concrete5.zip && \
    rm -v concrete5.zip && \
    rm -v /var/www/html/index.html

# Persist website user data, logs & apache config
VOLUME [ "/var/www/html", "/var/log/apache2", "/etc/apache2" ]

EXPOSE 80 443
WORKDIR /var/www/html

COPY docker-entrypoint /docker-entrypoint

ENTRYPOINT ["/docker-entrypoint"]
CMD ["apache2-foreground"]
