#!/system/bin/sh
MODDIR=${0%/*}

# --- Functions ---
print_modname() {
  ui_print "*****************************************"
  ui_print  "             RamRevyGtx                  "
  ui_print "*****************************************"
}

abort_with_warning() {
  ui_print "$1"
  ui_print "Aborting module execution for safety."
  exit 1 
}

is_service_active() {
  service list | grep -q "$1"
}

# --- Tweaking Virtual Memory ---
print_modname()
ui_print "- Tweaking virtual memory for gaming..."

echo "0" > /proc/sys/vm/swappiness
echo "2048" > /sys/block/mmcblk0/queue/read_ahead_kb
echo "2048" > /sys/block/mmcblk1/queue/read_ahead_kb

# --- Modifying Activity Manager Settings ---
ui_print "- Modifying Activity Manager settings for gaming..."

# Detect Android version
android_version=$(getprop ro.build.version.release)

# Disable MIUI's periodic cleaner service (if it exists)
if is_service_active "PeriodicCleaner"; then
  stop PeriodicCleaner
fi

# Determine optimal values based on RAM size (adjust as needed)
ram_size_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
if [ "$ram_size_kb" -ge 12000000 ]; then  # 12GB or more
    max_cached_processes=180
    max_phantom_processes=1073741823  # Essentially unlimited
    max_empty_time_millis=43200000  # 5 days
elif [ "$ram_size_kb" -ge 8000000 ]; then  # 8GB to 12GB
    max_cached_processes=160
    max_phantom_processes=536870912   # Half of unlimited
    max_empty_time_millis=34560000  # 4 days
else
    max_cached_processes=120
    max_phantom_processes=268435456   # Quarter of unlimited
    max_empty_time_millis=25920000  # 3 days
fi

if [ "$android_version" -ge 10 ]; then
  # Android 10 and above
  device_config set_sync_disabled_for_tests persistent
  device_config put activity_manager max_cached_processes "$max_cached_processes"
  device_config put activity_manager max_phantom_processes "$max_phantom_processes"
  settings put global settings_enable_monitor_phantom_procs false
  device_config put activity_manager max_empty_time_millis "$max_empty_time_millis"
elif [ "$android_version" -eq 9 ]; then
  # Android 9
  settings put global activity_manager_constants max_cached_processes="$max_cached_processes"
  settings put global settings_enable_monitor_phantom_procs false
fi

# --- Additional RAM Management Tweaks ---
ui_print "- Applying additional RAM management tweaks..."

# Aggressive Cache Cleaning and Memory Management

ui_print " - Clearing caches..."
sync
echo 3 > /proc/sys/vm/drop_caches
echo 2 > /proc/sys/vm/drop_caches
sleep 1  # Add a short delay for sync to complete

ui_print " - Trimming unused memory..."
for app in $(ls -d /proc/[0-9]*/); do
  awk '/VmRSS/ { sum += $2 } END { print sum }' "$app"/status > /dev/null  # Check only resident memory
  if [ $? -eq 0 ]; then
    mem_usage=$(cat "$app"/status | awk '/VmRSS/ { sum += $2 } END { print sum }')
    if [ "$mem_usage" -lt 524288 ]; then  # Trim apps using less than 512MB RAM (adjust as needed)
      echo 3 > "$app"/oom_score_adj  # Increase oom_score_adj to make app killable
    fi
  fi
done

# --- Optional Tweaks (Require Custom Kernel) ---
ui_print "- Applying optional tweaks (custom kernel required)..."

# 0 zRAM size
swapoff /dev/block/zram0
echo 0M > /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon /dev/block/zram0

ui_print "- Done"