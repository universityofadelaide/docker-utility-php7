FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# Configured timezone.
ENV TZ=Australia/Adelaide
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Ensure UTF-8.
RUN locale-gen en_AU.UTF-8
ENV LANG       en_AU.UTF-8
ENV LC_ALL     en_AU.UTF-8

# Use nearby apt mirror.
#RUN sed -i 's%http://archive.ubuntu.com/ubuntu/%mirror://mirrors.ubuntu.com/mirrors.txt%' /etc/apt/sources.list

# Install the universe.
RUN apt-get update \
&& apt-get -y install apt-transport-https ca-certificates \
&& apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
&& echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list \
&& apt-get update \
&& apt-get -y dist-upgrade \
&& apt-get -y install docker-engine \
&& apt-get -y install php7.0 php7.0-cli php7.0-common php7.0-gd php7.0-curl php7.0-opcache php7.0-mysql php7.0-ldap php-xdebug php-memcached php7.0-xml php7.0-mbstring php7.0-bcmath libedit-dev tig vim wget curl ssh git-flow silversearcher-ag mysql-client netcat-openbsd pv ruby-dev rubygems-integration nodejs nodejs-legacy npm build-essential sudo zip ssmtp python \
&& apt-get -y autoremove \
&& apt-get autoclean \
&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install bundler.
RUN gem install bundler

# Install Robo.
#RUN wget -O /usr/local/bin/robo http://robo.li/robo.phar && chmod +x /usr/local/bin/robo \

# Install Composer, Drupal Console and Drush.
RUN wget -q https://getcomposer.org/installer -O - | php -- --install-dir=/usr/local/bin --filename=composer \
&& wget https://drupalconsole.com/installer -O /usr/local/bin/drupal && chmod +x /usr/local/bin/drupal && /usr/local/bin/drupal init \
&& ln -s /web/vendor/drush/drush/drush /usr/local/bin/drush

# Build Robo from Git
RUN git clone --branch 1.0.0-RC1 --depth 1 https://github.com/consolidation-org/Robo.git /tmp/robo && cd /tmp/robo && composer --no-dev install \
&& echo "phar.readonly = Off" > /etc/php/7.0/cli/conf.d/99-phar_build.ini \
&& ./robo phar:build && mv robo.phar /usr/local/bin/robo && chmod +x /usr/local/bin/robo

# Add smtp support.
RUN echo "sendmail_path = /usr/sbin/ssmtp -t" > /etc/php/7.0/mods-available/sendmail.ini \
&& echo "mailhub=mail:25\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf \
&& phpenmod -v ALL -s ALL sendmail

# Enable sshd.
RUN mkdir -p /var/run/sshd && chmod -775 /var/run/sshd

COPY ./files/bash_aliases /root/.bash_aliases
COPY ./files/gitconfig /root/.gitconfig
COPY ./files/profile /root/.profile
COPY ./files/entry.sh /entry.sh

# Setup a diurectory ready for the user which is dynamically created.
RUN mkdir -p /code

COPY ./files/bash_aliases /code/.bash_aliases
COPY ./files/gitconfig /code/.gitconfig
COPY ./files/profile /code/.profile

# Expose ports.
EXPOSE 22

WORKDIR /code

CMD ["/usr/sbin/sshd", "-D"]
