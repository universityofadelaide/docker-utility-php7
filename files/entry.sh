#!/bin/bash

if [ "${USER}" != "root" ]; then
    chown -R ${UID}:${UID} /code
    adduser --disabled-password --uid ${UID} --gecos ${USER} --home /code ${USER}
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER}
    echo "Defaults env_keep += \"SSH_AUTH_SOCK\"" >> /etc/sudoers.d/${USER}
    if [ ${#} -eq 0 ]; then
        sudo -E -i -u ${USER}
    else
        sudo -E -i -u ${USER} -- sh -c "${*}"
    fi
else
    if [ ${#} -eq 0 ]; then
        sudo -E -i
    else
        sudo -E -i -- sh -c "${*}"
    fi
fi
