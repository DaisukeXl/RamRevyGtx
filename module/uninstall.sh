#!/system/bin/sh

# Delete / reset Activity Manager's variables set by the module and system will use the Activity Manager's default settings after a restart:
[ $(getprop ro.build.version.release) -gt 9 ] && cmd device_config set_sync_disabled_for_tests none
[ $(getprop ro.build.version.release) -gt 9 ] && cmd device_config delete activity_manager max_cached_processes || settings delete global activity_manager_constants
[ $(getprop ro.build.version.release) -gt 9 ] && cmd device_config delete activity_manager max_phantom_processes
[ $(getprop ro.build.version.release) -gt 9 ] && cmd settings reset global settings_enable_monitor_phantom_procs
[ $(getprop ro.build.version.release) -gt 9 ] && cmd device_config delete activity_manager max_empty_time_millis
[ $(getprop ro.build.version.release) -gt 9 ] && cmd settings delete global settings_enable_monitor_phantom_procs

echo "Please restart the device to make sure RescueParty and RollbackManager restore the default settings."
