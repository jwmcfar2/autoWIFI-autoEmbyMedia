#!/bin/bash

echo -e "\nThis script will simply run the following commands:"
echo -e "    - sudo cp src/*.sh /usr/local/sbin/"
echo -e "    - sudo cp src/autoWIFIHelper@.service /etc/systemd/system/"
echo -e "    - sudo cp src/99-usb.rules /etc/udev/rules.d/\n"

read -p $'Continue? (y/n): ' userInput
if [[ $userInput != *[yY]* ]]; then
    echo -e "\n\tExited.\n"
    break
fi

if [[ $EUID -ne 0 ]]; then
  echo -e "This script must be run as super-user/root (run 'sudo $(basename "$0")')"
  exit 1
fi

echo -e "\nMoving files from src/ and changing permissions...\n"

sudo cp src/*.sh /usr/local/sbin/
sudo cp src/autoWIFIHelper@.service /etc/systemd/system/
sudo cp src/99-usb.rules /etc/udev/rules.d/

sudo chmod 777 /usr/local/sbin/*.sh
sudo chmod 777 /etc/systemd/system/autoWIFIHelper@.service
sudo chmod 777 /etc/udev/rules.d/99-usb.rules

sudo udevadm control --reload-rules
sudo udevadm trigger
sudo systemctl daemon-reload

echo -e "\t...Finished installing autoWIFI + autoEmbyMedia.\n"
