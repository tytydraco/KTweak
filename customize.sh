#!/system/bin/sh
# Written by Draco (tytydraco @ GitHub)

ui_print "[*] Setting executable permissions..."
set_perm_recursive "$MODPATH/systen/bin" root root 0777 0755

# Do install-time script execution
sh "$MODPATH/system/bin/ktweak"
echo "[*] Executed service script during live boot. Reboot is not needed."
