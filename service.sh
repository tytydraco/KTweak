#!/system/bin/sh

while [[ "$(getprop sys.boot_completed)" -ne 1 ]] && [[ ! -d "/sdcard" ]]
do
       sleep 5
done

sleep 30
ktweak
