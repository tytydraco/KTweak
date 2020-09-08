#!/system/bin/sh
# Written by Draco (tytydraco @ GitHub)

ui_print "[*] Setting executable permissions..."
set_perm_recursive "$MODPATH/system/bin" root root 0777 0755

# Do install-time script execution
ui_print "[*] Executing during live boot..."
sh "$MODPATH/system/bin/ktweak"
