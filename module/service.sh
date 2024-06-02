#!/system/bin/sh
# Virtual memory tweaks - not really needed anymore
# stop perfd
# echo '40' > /proc/sys/vm/swappiness
# echo '0' > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
# echo '25' > /proc/sys/vm/vfs_cache_pressure
# echo '128' > /sys/block/mmcblk0/queue/read_ahead_kb
# echo '128' > /sys/block/mmcblk1/queue/read_ahead_kb
# echo '16384' > /proc/sys/vm/min_free_kbytes
# echo '0' > /proc/sys/vm/oom_kill_allocating_task
# echo '10' > /proc/sys/vm/dirty_ratio
# echo '5' > /proc/sys/vm/dirty_background_ratio
# chmod 666 /sys/module/lowmemorykiller/parameters/minfree
# chown root /sys/module/lowmemorykiller/parameters/minfree
# echo '30720,40960,51200,61440,71680,81920' > /sys/module/lowmemorykiller/parameters/minfree
# rm /data/system/perfd/default_values
# start perfd
# sleep 20

# Set Activity Manager's max. cached app number -> 160 (instead of the default 32 (or even lower 24):
# Disable MIUI's periodic cleaner service (PeriodicCleaner - check your logcat..)
# Obviously will throw an error if periodic service doesn't exist
# but at the moment I'm a bit lazy to implement proper SDK testing and exception handling..
# In case it throws an error - it just doesn't exist / won't work. Sorry  -.-'
sleep 180

[ $(getprop ro.build.version.release) -gt 9 ] && cmd device_config set_sync_disabled_for_tests persistent
[ $(getprop ro.build.version.release) -gt 9 ] && cmd device_config put activity_manager max_cached_processes 256 || settings put global activity_manager_constants max_cached_processes=256
[ $(getprop ro.build.version.release) -gt 9 ] && cmd device_config put activity_manager max_phantom_processes 2147483647
[ $(getprop ro.build.version.release) -gt 9 ] && cmd settings put global settings_enable_monitor_phantom_procs false
[ $(getprop ro.build.version.release) -gt 9 ] && cmd device_config put activity_manager max_empty_time_millis 86400000
[ $(getprop ro.build.version.release) -gt 9 ] && cmd settings put global settings_enable_monitor_phantom_procs false
