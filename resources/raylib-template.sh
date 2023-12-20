#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"  # Location for ArkOS which is mapped from /roms/tools or /roms2/tools for devices that support 2 sd cards and have them in use.
elif [ -d "/opt/tools/PortMaster/" ]; then # Location for TheRA
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster" # Location for 351Elec/AmberElec, JelOS, uOS and RetroOZ
fi

source $controlfolder/control.txt

GAMEDIR="/$directory/ports/raylib-template/"
cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$ESUDO chmod 666 $CUR_TTY
$ESUDO chmod 666 raylib-template
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt

## RUN SCRIPT HERE

echo "Starting game." > $CUR_TTY

$TASKSET ./raylib-template 2>&1 | $ESUDO tee -a ./log.txt

$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY
