FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# Ensure UTF-8
RUN locale-gen en_AU.UTF-8
ENV LANG       en_AU.UTF-8
ENV LC_ALL     en_AU.UTF-8

# Use nearby apt mirror
COPY ./files/sources.list /etc/apt/sources.list
RUN sed -i.bak "s/<mirror>/http:\/\/mirror.internode.on.net\/pub\/ubuntu\/ubuntu/g" /etc/apt/sources.list
RUN sed -i.bak "s/<version>/$(sed -n "s/^.*CODENAME=\(.*\)/\1/p" /etc/lsb-release)/g" /etc/apt/sources.list

# Start by adding/updating required software
RUN apt-get update
RUN apt-get -y install apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo "deb https://apt.dockerproject.org/repo ubuntu-wily main" > /etc/apt/sources.list.d/docker.list

# Update again now with the extra repos
RUN apt-get update
RUN apt-get -y dist-upgrade

# Install new packages we need
RUN apt-get -y --force-yes install docker-engine

# Configure timezone
RUN echo "Australia/Adelaide" > /etc/timezone; dpkg-reconfigure tzdata

RUN apt-get -y install php7.0 php7.0-cli php7.0-common php7.0-gd php7.0-curl php7.0-opcache php7.0-mysql php7.0-ldap php-xdebug php7.0-xml php7.0-mbstring php7.0-bcmath libedit-dev tig vim wget curl ssh git-flow silversearcher-ag mysql-client netcat-openbsd pv ruby rubygems-integration nodejs nodejs-legacy sudo zip

# Install robo
RUN wget -O /usr/local/bin/robo http://robo.li/robo.phar && chmod +x /usr/local/bin/robo

# Install composer
RUN wget -q https://getcomposer.org/installer -O - | php -- --install-dir=/usr/local/bin --filename=composer

# Install Drupal console
RUN wget https://drupalconsole.com/installer -O /usr/local/bin/drupal && chmod +x /usr/local/bin/drupal
RUN /usr/local/bin/drupal init

# Setup Drush symlink in advance
RUN ln -s /code/vendor/drush/drush/drush /usr/local/bin/drush

# Install powerline-shell.
RUN wget -O /root/.powerline-shell.py https://raw.githubusercontent.com/universityofadelaide/ua-powerline-shell/master/powerline-shell.py
RUN chmod 755 /root/.powerline-shell.py

# Add smtp support
RUN apt-get -y install ssmtp
RUN echo "mailhub=mail:25\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf
RUN echo "sendmail_path = /usr/sbin/ssmtp -t" > /etc/php/7.0/mods-available/sendmail.ini

RUN echo "date.timezone=\"Australia/Adelaide\"" > /etc/php/7.0/cli/conf.d/30-custom.ini
RUN phpenmod -v ALL -s ALL sendmail

# enable sshd
RUN mkdir -p /var/run/sshd && chmod -775 /var/run/sshd

COPY ./files/bash_aliases /root/.bash_aliases
COPY ./files/gitconfig /root/.gitconfig
COPY ./files/profile /root/.profile

RUN apt-get -y autoclean
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ports
EXPOSE 22

WORKDIR /code

CMD ["/usr/sbin/sshd", "-D"]
