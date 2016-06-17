#!/bin/bash

if [ "${USER}" != "root" ]; then
    adduser --disabled-password --gecos ${USER} --home /code ${USER}
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER}
    echo "Defaults env_keep += \"SSH_AUTH_SOCK\"" >> /etc/sudoers.d/${USER}
    sudo -E -i -u ${USER}
else
    sudo -E -i
fi
