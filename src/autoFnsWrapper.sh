#!/bin/bash
#
# Wrapper for auto(Functions)
# Allows single udev event to
# Call these functions in order

logfile=/usr/local/sbin/autoWrapper.log
if [[ ! -f $logfile || $(find $logfile -type f -mmin +2) ]]; then
    > $logfile
    chmod 666 $logfile
fi
echo -e "The device triggering the event is: $DEVNAME \n\tTimestamp = ($(date))\n" >> $logfile

/usr/local/sbin/autoWIFI.sh $DEVNAME
/usr/local/sbin/autoMediaMount.sh $DEVNAME