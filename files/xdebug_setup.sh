#!/bin/bash

export DEFAULT_ROUTE=$(ip route | grep default | awk '{ print $3 }')

sudo bash -c "cat > /etc/php/7.0/cli/conf.d/20-xdebug.ini" <<EOF
zend_extension=xdebug.so
xdebug.idekey=PHPSTORM
xdebug.max_nesting_level=500
xdebug.remote_autostart=1
xdebug.remote_connect_back=1
xdebug.remote_enable=1
xdebug.remote_port=9001
xdebug.remote_host=${DEFAULT_ROUTE}
EOF
