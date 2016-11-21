#!/bin/bash

if [ "${USER}" != "root" ]; then
    chown -R ${UID}:${UID} /code
    adduser --disabled-password --uid ${UID} --gecos ${USER} --home /code ${USER}
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER}
    echo "Defaults env_keep += \"SSH_AUTH_SOCK\"" >> /etc/sudoers.d/${USER}
    sudo -E -i -u ${USER} -- sh -c "${*}"
else
    sudo -E -i -- sh -c "${*}"
fi
