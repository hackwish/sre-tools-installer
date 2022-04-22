#!/bin/bash

if [ "$(id -u)" != "0" ]; then
  echo "Este script debe ejecutarse como root (sudo)." >&2
  exit 1
fi

# Bootstraping
#set -e

# Load up the release information
export OS_LIKE=`cat /etc/os-release | grep ID_LIKE | cut -d '=' -f 2`
export DISTRIB_CODENAME=`cat /etc/os-release | grep VERSION_CODENAME | cut -d '=' -f 2`  # `lsb_release -c -s`
export ARCHITECTURE=`uname -a | awk '{print $13}'`
# DISTRIB_CODENAME=`lsb_release -c -s`

echo ${OS_LIKE}

if [ ${OS_LIKE} == 'ubuntu' ]  || [ ${OS_LIKE} == 'debian' ]; then
    # install that if we have to.
    which lsb_release && apt-get --yes install lsb-release
    
    apt-add-repository universe
    apt-add-repository multiverse

    echo "Vamos a verificar si tiene Ansible y que distribución usas..."

    # Ubuntu distros
    if [ ${DISTRIB_CODENAME} == 'bionic' ] || [ ${DISTRIB_CODENAME} == 'disco' ] || [ ${DISTRIB_CODENAME} == 'eoan' ]; then
        echo "Adding Ansible PPA"
        apt-add-repository --yes ppa:ansible/ansible
    # Other Ubuntu-based distros
    elif [ ${DISTRIB_CODENAME} == 'tricia' ] || [ ${DISTRIB_CODENAME} == 'tina' ] || [ ${DISTRIB_CODENAME} == 'tessa' ] || [ ${DISTRIB_CODENAME} == 'tara' ] || [ ${DISTRIB_CODENAME} == 'hera' ] || [ ${DISTRIB_CODENAME} == 'juno' ]; then
        echo "Manual adding Ansible PPA"
        echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu bionic main" >> /etc/apt/sources.list.d/ansible-ubuntu-ansible-bionic.list
    else
        echo "NOT Adding Ansible PPA"
        echo $DISTRIB_CODENAME
    fi

    echo "Actualizando el sistema..."
    apt-get update && apt-get -y --force-yes upgrade

    echo "Instalando dependencias previas"
    apt-get install -y 
        apt-transport-https \
        curl \
        git \
        python-is-python3 \
        python3 \
        python3-pip \
        rsync \
        software-properties-common \
        wget

    modprobe ip_conntrack

    DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" ansible

    echo "Ahora vamos a adecuar la instalación..."

    # Fix Ubuntu codenames for based distros
    echo "CodeName ANTES: $DISTRIB_CODENAME"
    # Linux Mint distros
    if [ ${DISTRIB_CODENAME} == 'ulyana' ] || [ ${DISTRIB_CODENAME} == 'ulyssa' ] || [ ${DISTRIB_CODENAME} == 'uma' ] || [ ${DISTRIB_CODENAME} == 'una' ]; then
        echo $DISTRIB_CODENAME
        export DISTRIB_CODENAME='focal'
    elif  [ ${DISTRIB_CODENAME} == 'tricia' ] || [ ${DISTRIB_CODENAME} == 'tina' ] || [ ${DISTRIB_CODENAME} == 'tessa' ] || [ ${DISTRIB_CODENAME} == 'tara' ]; then
        echo $DISTRIB_CODENAME
        export DISTRIB_CODENAME='bionic'
    # ElementaryOS distros
    elif [ ${DISTRIB_CODENAME} == 'odin' ]; then
        echo $DISTRIB_CODENAME
        export DISTRIB_CODENAME='focal'
    elif [ ${DISTRIB_CODENAME} == 'hera' ] || [ ${DISTRIB_CODENAME} == 'juno' ]; then
        echo $DISTRIB_CODENAME
        export DISTRIB_CODENAME='bionic'
    else
        echo $DISTRIB_CODENAME
        export DISTRIB_CODENAME=`lsb_release -c -s`
    fi

    # Workaround Linux Mint 20 no Snaps Support
    rm -f /etc/apt/preferences.d/nosnap.pref
else
    echo "No hay nada que hacer aquí"
    exit0;
fi
echo "CodeName AHORA: $DISTRIB_CODENAME"

#Ansible
echo "Iniciando Ansible Deploy"

echo "Descargando requirements"
ansible-galaxy install --force -r requirements.yml

echo "Comienza Deployment con Ansible"
ansible-playbook -vvv -i ansible/inventory ansible/sre-linux.yml

echo "¡Por ahora estamos listos!"
