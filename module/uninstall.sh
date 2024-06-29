#!/system/bin/sh
MODDIR=${0%/*}

# --- Functions ---
print_modname() {
  ui_print "*****************************************"
  ui_print "               RamRevyGtx                "
  ui_print "*****************************************"
}

# Function to abort with a warning message
abort_with_warning() {
  ui_print "$1"
  ui_print "Aborting module uninstallation."
  exit 1
}

# Function to ask the user for confirmation
confirm_uninstall() {
  ui_print "Are you sure you want to uninstall YourModuleName?"
  ui_print "This will restore the original RAM management settings."
  local choice
  while true; do
    ui_print "[Volume Up] - Yes [Volume Down] - No"
    read choice
    case "$choice" in
      1) return 0 ;;  # Yes
      0) abort_with_warning "- Uninstallation cancelled by user." ;;
      *) ui_print "Invalid choice. Press Volume Up for Yes or Volume Down for No." ;;
    esac
  done
}

# --- Uninstallation ---

print_modname()  # Print the module name
confirm_uninstall  # Ask the user for confirmation

ui_print "- Restoring RAM management settings..."

# Reset system properties to their default values (add the properties modified by your module)
resetprop ro.sys.fw.bg_apps_limit 
resetprop ro.vendor.qti.sys.fw.bg_apps_limit 
resetprop ro.vendor.qti.sys.fw.bservice_enable 
resetprop ro.vendor.qti.sys.fw.bservice_age 
resetprop ro.vendor.qti.sys.fw.bservice_limit 
resetprop ro.config.max_empty_processes 
resetprop ro.lmk.low 
resetprop ro.lmk.medium 
resetprop ro.lmk.critical 
resetprop ro.lmk.upgrade_pressure 
resetprop ro.lmk.downgrade_pressure 
resetprop ro.zram.enabled 
resetprop ro.config.low_ram 
resetprop ro.sys.fw.use_trim_settings 
resetprop ro.sys.fw.empty_app_percent 
resetprop ro.sys.fw.trim_empty_app 
resetprop ro.sys.fw.trim_cache_app 
resetprop ro.config.fha_enable 

# Restore files from backup (if available)
if [ -f "$INFO" ]; then
  while read LINE; do
    if [ "$(echo -n "$LINE" | tail -c 1)" == "~" ]; then
      continue  # Skip backup files
    elif [ -f "$LINE~" ]; then
      ui_print "  - Restoring $LINE"
      mv -f "$LINE~" "$LINE"  # Restore the backup
    else
      ui_print "  - Removing $LINE"
      rm -f "$LINE"  # Remove the module file

      # Remove empty directories recursively
      while true; do
        LINE=$(dirname "$LINE")
        if [ "$(ls -A "$LINE" 2>/dev/null)" ]; then
          break  # Exit loop if directory is not empty
        else
          rm -rf "$LINE"  # Remove empty directory
        fi
      done
    fi
  done < "$INFO"
  rm -f "$INFO"  # Remove the $INFO file
else
  ui_print "- $INFO file not found. It may have already been uninstalled."
fi

ui_print "- Uninstallation complete!"
