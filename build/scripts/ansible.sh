#!/bin/bash
IMAGE="ansible-image"
VERSION="latest"

function addMount {
  [ -z ${ANSIBLE_MOUNTS+x} ] && ANSIBLE_MOUNTS="$1" || ANSIBLE_MOUNTS="$1 $ANSIBLE_MOUNTS"
}

function die {
  echo -e "$1"
  exit ${2:-1}
}

# SSH Socket nach Docker übergeben, falls vorhanden
if [ -S "$SSH_AUTH_SOCK" ]; then
  SSHAUTSOCKENVSWITCH="-e SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
  addMount $SSH_AUTH_SOCK
else
  SSHAUTSOCKENVSWITCH=
  echo "[WARN] SSH-Agent nicht aktiv"
fi

# Wenn KUBCONFIG gesetzt und ein File, dann mounten und Varibale für K8S Modul setzen
if [ -f "$KUBECONFIG" ]; then
  K8S="-e K8S_AUTH_KUBECONFIG=$KUBECONFIG"
  addMount $KUBECONFIG
else
  KUBECONFIG=
fi

#Aufruf prüfen, muss ein valides ansible kommando sein
scriptInvocationName=`basename "$0"`
case "$scriptInvocationName" in
	ansible|ansible-config|ansible-connection|ansible-console|ansible-doc|ansible-galaxy|ansible-inventory|ansible-playbook|ansible-pull|ansible-vault) ;;
	*)	echo "$scriptInvocationName ist kein gültiges ansible Kommando";
		exit 1 ;;
esac

#add pwd to mount
addMount "$(pwd):/ansible"

#vault_password_file aus ansible.cfg mounten
if [ -f $(pwd)/ansible.cfg ] && [ -z "$ANSIBLE_VAULTPASSWORDFILE" ]; then
  ANSIBLE_VAULTPASSWORDFILE=$( grep '^vault_password_file' $(pwd)/ansible.cfg | cut -d'=' -f2- | xargs echo -n )
  [[ ! -z ${ANSIBLE_VAULTPASSWORDFILE+x} ]] && addMount "$ANSIBLE_VAULTPASSWORDFILE:$ANSIBLE_VAULTPASSWORDFILE:ro"
fi

#zusätzliche bind mounts generieren
ANSIBLE_MOUNTSTRING=""
if [[ ! -z ${ANSIBLE_MOUNTS+x} ]]; then
  for mp in $ANSIBLE_MOUNTS; do
    [[ "$mp" =~ .*":".* ]]  && ANSIBLE_MOUNTSTRING="-v $mp $ANSIBLE_MOUNTSTRING" || ANSIBLE_MOUNTSTRING="-v $mp:$mp $ANSIBLE_MOUNTSTRING"
  done
fi

#Konsolenfarben aktivieren
if [ -t 1 ]; then
  DOCKER_TTY='-ti'
else
  DOCKER_TTY=''
fi

# Logeinstellungen
#  -> Loggen über Ansible direkt nach Splunk. Daher braucht Docker selbst nicht loggen
DOCKER_LOGSETTINGS='--log-driver none'

docker run --rm $DOCKER_TTY $DOCKER_LOGSETTINGS $ANSIBLE_MOUNTSTRING -e ANSIBLEUSER=$(id -u) -e ANSIBLEUSERNAME=$(id -u -n) -e ANSIBLEGROUP=$(id -g) -e ANSIBLEGROUPNAME=$(id -g -n) $SSHAUTSOCKENVSWITCH $K8S $IMAGE:$VERSION $scriptInvocationName $@
