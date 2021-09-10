#!/bin/bash

# Setup
if [ $# -eq 0 ]; then
  echo
  echo "Bitte dieses Image über die ansible-Befehle aufrufen!"
  echo
  echo "Einmalig muss ein Setup je Nutzer erfolgen mit:"
  echo '  docker run --rm -it -v $HOME:/setup -e ANSIBLEUSER=$(id -u) -e ANSIBLEUSERNAME=$(id -u -n) -e ANSIBLEGROUP=$(id -g) -e ANSIBLEGROUPNAME=$(id -g -n) ansible-image /setup.sh'
  echo
  exit 1
fi

# Als Root ausführen
if [ -z "${ANSIBLEUSER}" ] || [ -z "${ANSIBLEUSERNAME}" ] || [ -z "${ANSIBLEGROUP}" ] || [ -z "${ANSIBLEGROUPNAME}" ]; then
  echo "Nicht alle ANSIBLE-Variablen gesetzt. Image sollte nicht als root ausgeführt werden!"
  echo " - ANSIBLEUSER:      ${ANSIBLEUSER:-not set}"
  echo " - ANSIBLEUSERNAME:  ${ANSIBLEUSERNAME:-not set}"
  echo " - ANSIBLEGROUP:     ${ANSIBLEGROUP:-not set}"
  echo " - ANSIBLEGROUPNAME: ${ANSIBLEGROUPNAME:-not set}"
  $@
  exit $?
fi

# ANSIBLE User Home existiert bereits. SSH-Key gemountet? User-Home Berechtigung gerade ziehen
[[ -d "/home/$ANSIBLEUSERNAME/" ]] && chown $ANSIBLEUSERNAME:$ANSIBLEGROUPNAME /home/$ANSIBLEUSERNAME/

# ANSIBLE User anlegen
groupadd -g $ANSIBLEGROUP $ANSIBLEGROUPNAME
useradd -g $ANSIBLEGROUP -u $ANSIBLEUSER -m -s /bin/bash $ANSIBLEUSERNAME

# Ansible Befehle ausführen
[[ -d /ansible ]] && cd /ansible
gosu $ANSIBLEUSER:$ANSIBLEGROUP $@
