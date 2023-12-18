# autoWIFI + autoEmbyMedia
An extension of my autoWIFI script - where a single udev USB event triggers my autoWIFI and autoMediaMount scripts. This will allow me to both use a drive to connect to a new wifi network, then auto-mount them to my designated Emby folder location. Then I use symbolic links to match genres to view on Emby.

Please refer to Emby's website for more information about their server software: **https://emby.media/**

Please refer to my other repo for more detailed info on autoWIFI (https://github.com/jwmcfar2/autoWIFI/)

# Setup

You can simply just run my script in the root of this repo (sudo may be needed): **./setup.sh**

OR

Setup is simple and can be done manually - there are only 3 single files needed:
  - The service file (`autoWIFIHelper@.service`), which allows for root commands (such as moving files and deleting wifi text file if this is successful) needs to be added to directory: **/etc/systemd/system/**
  - The udev rules file (`99-usb.rules`), which triggers an event every time a block device is detected for the first time (such as USB storage), which needs to go in directory: **/etc/udev/rules.d/**
  - The scripts themselves (`*.sh`), which is 99% of the functionality - you can put this anywhere, but you need to make sure the dir of the wrapper script (`autoFnsWrapper.sh`) matches the directory listed in `autoWIFIHelper@.service` -- By default I put this in **/usr/local/sbin/**

Then, be sure to restart udev / system services:

>sudo udevadm control --reload-rules
>
>sudo udevadm trigger
>
>sudo systemctl daemon-reload

# Use

Usage Summary: 
 - Plugging in USB storage will initiate my scripts (negligible performance impact, **_but_** if successful the drive remains mounted)
 - If it contains a *specifically formatted* text file called "autoWIFI.txt" (read 'Important Details' about 'autoWIFI'), this script will parse it for the ssid and password provided and connect the first discovered wlan device to it (deleting it on success)
 - Make sure your USB drive is storing any/all media in one of 3 folders (named *exactly* as such): 'Movies', 'Music', and 'TV_Shows'
 - After installing these scripts, your USB drives will be automatically mount to /media/emby_server/USB_Media/USB_#/ -- where '#' will start at '1' and continue upwards (or will choose the lowest number with an empty directory)
 - Once the USB drive is mounted, my script will create symbolic links (no data transfer) to the emby_server folders of the exact same names ('/media/emby_server/Movies/', '/media/emby_server/Music/', '/media/emby_server/TV_Shows/')
 - This allows you to connect several drives with the same naming convention, and these links will merge together in the emby_server categories (e.g. - USB_1/TV_Shows -> emby_server/TV_Shows && USB_2/TV_Shows -> emby_server/TV_Shows).

 Please refer to Emby on how to add these folder structures to your server (I would recommend adding the 3 genre folders I mentioned, PLUS the folder 'USB_Media', in case you cannot find something in the mentioned genres).

**Important Details:**
  - Please refer to my autoWIFI repo (https://github.com/jwmcfar2/autoWIFI/) for a detailed breakdown of autoWIFI. Quick summary: Simply plugging in a USB that contains a *specifically formatted* (see github repo or text file in example/) file called "autoWIFI.txt", will allow this script to parse it for the ssid and password provided and connect the first discovered wlan device to it. **NOTE: Even if you do not want this functionality - it will not affect your system since it will only do something when that specific file exists -- However, if you wish to ensure this functionality will never even attempt looking for it - just comment out the single line in autoFnsWrapper.sh that calls the autoWIFI.sh script.**
  - For auto mounting drives for Emby media server, I set it up to assume your Emby server folder structure will be: **/media/emby_server/** -- And my script will look in any connected USB drives for matching folder names, and link them (symbolic link, so no data transfer). I statically defined these folder names for simplicity (feel free to modify this). Refer to example/exampleRootFolderStructure.txt for a detailed breakdown of my assumed folder structure.

# Uninstall

I have added a simple uninstall script **uninstall.sh**, which will simply delete the files that I added via setup.sh (will prompt and warn you before it does, with exactly the commands it will run)

OR

If you have installed these files manually - best practice would be to delete them manually as well.

Once removed, either restart the entire system or run these commands to restart udev / system services:

>sudo udevadm control --reload-rules
>
>sudo udevadm trigger
>
>sudo systemctl daemon-reload
