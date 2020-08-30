#!/system/bin/sh
# Written by Draco (tytydraco @ GitHub)

# Wait for boot to finish completely
while [[ `getprop sys.boot_completed` -ne 1 ]] && [[ ! -d "/sdcard" ]]
do
       sleep 1
done

# Sleep an additional 60s to ensure init is finished
sleep 60

# Setup tweaks
ktweak
