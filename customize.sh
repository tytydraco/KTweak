#!/system/bin/sh

BRANCH="balance"
URL="https://raw.githubusercontent.com/tytydraco/KTweak/$BRANCH/ktweak"
SCRIPT_PATH="$MODPATH/system/bin/ktweak"

ui_print ""
ui_print " --- KTweak Magisk Module ---"
ui_print "     branch: $BRANCH         "
ui_print ""

ui_print " * Fetching script from GitHub..."
if command -v curl &> /dev/null
then
	curl -Lso "$SCRIPT_PATH" "$URL"
elif command -v wget &> /dev/null
then
	wget -qO "$SCRIPT_PATH" "$URL"
else
	ui_print " ! Missing curl and wget, bailing..."
	exit 1
fi

ui_print " * Hot patching for Android..."
sed -i 's|!/usr/bin/env bash|!/system/bin/sh|g' "$SCRIPT_PATH"

ui_print " * Setting executable permissions..."
set_perm_recursive "$SCRIPT_PATH" root root 0777 0755

ui_print " * Executing script immediately..."
sh "$SCRIPT_PATH"

ui_print ""
ui_print " --- Additional Notes ---"
ui_print ""
ui_print " * Reinstall to update the script""
ui_print " * Rebooting is not required"
ui_print " * Do not use with other optimizer modules"
ui_print " * Report issues to @ktweak_discussion on Telegram"
ui_print " * Contact @tytydraco for direct support"
ui_print " * Source code is available on GitHub"
ui_print ""
ui_print "   https://www.github.com/tytydraco/ktweak"
ui_print ""
