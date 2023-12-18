#!/bin/bash

echo -e "\nThis script will simply run the following commands:"
echo -e "    - sudo rm /usr/local/sbin/*.sh"
echo -e "    - sudo rm /etc/systemd/system/autoWIFIHelper@.service"
echo -e "    - sudo rm /etc/udev/rules.d/99-usb.rules\n"

read -p $'Continue? (y/n): ' userInput
if [[ $userInput != *[yY]* ]]; then
    echo -e "\n\tExited.\n"
    break
fi

if [[ $EUID -ne 0 ]]; then
  echo -e "This script must be run as super-user/root (run 'sudo $(basename "$0")')"
  exit 1
fi

sudo rm /usr/local/sbin/*.sh
sudo rm /etc/systemd/system/autoWIFIHelper@.service
sudo rm /etc/udev/rules.d/99-usb.rules

sudo udevadm control --reload-rules
sudo udevadm trigger
sudo systemctl daemon-reload

echo -e "\t...Finished Uninstalling autoWIFI + autoEmbyMedia.\n"
