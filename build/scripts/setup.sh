#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

#bin Verzeichnis erzeugen
mkdir -p /setup/bin
cd /setup/bin

#Wrapperfile definieren
ansibleWrapperFile="ansible-wrapper.sh"

#wrapper kopieren
[[ ! -e "$ansibleWrapperFile" ]] && echo "Adding $ansibleWrapperFile ..." || echo "Updating $ansibleWrapperFile ..."
cp /ansible.sh $ansibleWrapperFile
chmod +rx $ansibleWrapperFile

#linken
for cmd in ansible ansible-config ansible-connection ansible-console ansible-doc ansible-galaxy ansible-inventory ansible-playbook ansible-pull ansible-vault; do
  [[ ! -e $cmd ]] && echo "Adding $cmd ..." && ln -s $ansibleWrapperFile $cmd || echo "$cmd exists"
done


