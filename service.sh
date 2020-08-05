#!/system/bin/sh
# Written by Draco (tytydraco @ GitHub)

# Wait 60s into boot before applying changes
echo "[*] Waiting for 60s of uptime."
while [[ `cat /proc/uptime | awk '{print $1}' | awk -F. '{print $1}'` -lt 60 ]]
do
	sleep 1
done
echo "[*] Done waiting."

# Setup tweaks
ktweak
