#!/bin/bash

echo " "
echo "RGB30 Linux Setup Script"
echo " "
echo "Please ensure that the RGB30 is powered on and is connected to the same" 
echo "network as this device before continuing."

if [ -z "$RGB30_SSH_LOCAL_IP" ] || [ -z "$RGB30_SSH_PASSWORD" ]
then
    echo "************************************************************************"
    echo "* Local IP: Start > Network Settings > Information > IP Address        *"
    echo "* Enable SSH: Start > Network Settings > Network Services > Enable SSH *"
    echo "* Password: Start > System Settings > Authentication > Root Password   *"
    echo "************************************************************************"
fi

# prompt for ssh local ip
if [ -z "$RGB30_SSH_LOCAL_IP" ]
then
    echo "Please enter local IP address for device:"
    read local_ip
    echo "export RGB30_SSH_LOCAL_IP=$local_ip" >> ~/.bashrc
    export RGB30_SSH_LOCAL_IP=$local_ip
fi

# prompt for ssh passwords
if [ -z "$RGB30_SSH_PASSWORD" ]
then
    echo "Please enter device's root password:"
    read -s ssh_password
    echo "export RGB30_SSH_PASSWORD=$ssh_password" >> ~/.bashrc
    export RGB30_SSH_PASSWORD=$ssh_password
fi

# install dependencies and initialize rgb30
echo " "
# if packages not installed
if ! dpkg -s make sshpass gcc libgles2-mesa-dev libdrm-dev libgbm-dev > /dev/null 2>&1
then
    echo "Installing dependencies..."
    sudo apt update
    sudo apt install -y make sshpass gcc libgles2-mesa-dev libdrm-dev libgbm-dev
fi
make initialize_rgb30
