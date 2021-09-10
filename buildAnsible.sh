#!/bin/bash

set -e # exit on error
set -o pipefail

function showNewerPypiAvailable()
{
  #Param 1 = Packagename
  #Param 2 = Version to install
  return
  latest=$(curl --fail -sS https://pypi.org/pypi/$1/json | jq -r .info.version)
  if [ "$latest" != "$2" ]; then
    echo "[WARN] von $1 ist die Version $latest verfuegbar, es wird jedoch Version $2 installiert"
  fi
}

a=$(which jq)
if [ $? -ne 0  ]; then
  mkdir -p ~/bin
  curl -o ~/bin/jq -s "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
  chmod +x ~/bin/jq
  export PATH=$HOME/bin:$PATH
fi

#version to install
ansible="4.5.0"

showNewerPypiAvailable "ansible" $ansible

tagDev=dev-${USER}

docker build --build-arg ansibleVersion=$ansible ./build -t ansible-image:$tagDev # --build-arg http_proxy=$HTTP_PROXY --build-arg https_proxy=$HTTPS_PROXY

echo
echo "Docker image ist ansible-image:$tagDev"
