#!/bin/bash

DEVNAME=$1
# Create new logfile if existing log is older than 2 minutes...
logfile="/usr/local/sbin/autoMedia.log"
if [[ ! -f $logfile || $(find $logfile -type f -mmin +2) ]]; then
    > $logfile
    chmod 666 $logfile
fi

# Immediate exit if this is not an 'sd' device (can't be USB storage)
if [[ "$DEVNAME" != /dev/sd* ]]; then
    exit
fi
sleep 0.1

###########################################################
#
# Now, there will be only one instance that reaches here - mount drive and look for 'autoWIFI.txt'
##################################################################################################
#
# Check if $DEVNAME is set and is a block device
if [ -b "$DEVNAME" ]; then
    # Use lsblk to check if $DEVNAME is a USB device
    if lsblk -no TRAN "$DEVNAME" | grep -iq "usb"; then
        # It's a USB device; now find the first partition
        first_partition=$(lsblk -ln -o NAME "$DEVNAME" | grep "^${DEVNAME##*/}[0-9]" | head -n 1)
        if [ -n "$first_partition" ]; then
            first_partition="/dev/$first_partition"

            # Get the mount point
            baseDir="/media/emby_server"
            usbNumber=1
            while [[ -d "${baseDir}/USB_Media/USB_${usbNumber}" ]] && [[ "$(ls -A "${baseDir}/USB_Media/USB_${usbNumber}")" ]]; do
            ((usbNumber++))
            done
            mount_point="/media/emby_server/USB_Media/USB_${usbNumber}"

            # Create the mount point directory if it does not exist
            mkdir -p "$mount_point"

            # Attempt to mount the first partition
            mount "$first_partition" "$mount_point"

            # Check the exit status of last ran command (mount)
            if [ $? -eq 0 ]; then
                echo "Successfully mounted '$first_partition' to: $mount_point" >> $logfile
            else
                echo -e "\n\t(Did not execute: Failed to mount $first_partition)" >> $logfile
                exit
            fi

            ##########################
            # Now, create symlinks to matching media names for Emby...
            #
            # List of Emby Directories
            directories=('Movies' 'TV_Shows' 'Music')

            # Enable case-insensitive pattern matching
            shopt -s nocasematch

            for dir in "${directories[@]}"; do
                # Check if source directory exists
                if [ -d "${mount_point}/${dir}" ]; then
                    # Create symbolic links for each file/subdirectory that does not already have a link in baseDir
                    find "${mount_point}/${dir}" -mindepth 1 -maxdepth 1 | while read item; do
                    itemName=$(basename "$item")
                    # Check if destination file or directory exists with case-insensitive matching
                    if [ ! -e "${baseDir}/${dir}/${itemName}" ]; then
                        # Item does not exist, so create a symbolic link
                        ln -s "$item" "${baseDir}/${dir}/"
                        echo "Link created for '${itemName}' in '${baseDir}/${dir}/'" >> $logfile
                    else
                        echo "Item '${itemName}' already exists in '${baseDir}/${dir}/', skipping..." >> $logfile
                    fi
                    done
                else
                    echo "Source directory '${mount_point}/${dir}' does not exist, skipping..." >> $logfile
                fi
            done

            # Disable case-insensitive pattern matching
            shopt -u nocasematch

            ##########################
        else
            echo -e "\n\t(Did not execute: No partitions found on $DEVNAME)" >> $logfile
        fi
    else
        echo -e "\n\t(Did not execute: $DEVNAME is not a USB device)" >> $logfile
    fi
else
    echo -e "\n\t(Did not execute: Invalid block device: $DEVNAME)" >> $logfile
fi
##################################################################################################