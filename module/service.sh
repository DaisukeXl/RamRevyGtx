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

echo "40" > /proc/sys/vm/swappiness
echo "1024" > /sys/block/mmcblk0/queue/read_ahead_kb
echo "1024" > /sys/block/mmcblk1/queue/read_ahead_kb

# --- Modifying Activity Manager Settings ---
ui_print "- Modifying Activity Manager settings for gaming..."

# Detect Android version
android_version=$(getprop ro.build.version.release)

# Disable MIUI's periodic cleaner service (if it exists)
if is_service_active "PeriodicCleaner"; then
  stop PeriodicCleaner
fi

# Increase max cached processes for smoother multitasking
if [ "$android_version" -gt 9 ]; then  # Android 10+
    cmd device_config set_sync_disabled_for_tests persistent
    cmd device_config put activity_manager max_cached_processes 160
    cmd device_config put activity_manager max_phantom_processes 1073741823
    cmd settings put global settings_enable_monitor_phantom_procs false
    cmd device_config put activity_manager max_empty_time_millis 43200000
else  # Android 9 and below
    settings put global activity_manager_constants max_cached_processes=160
    settings put global settings_enable_monitor_phantom_procs false
fi

# --- Additional RAM Management Tweaks ---
ui_print "- Applying additional RAM management tweaks..."

# Aggressive Cache Cleaning
ui_print "  - Clearing caches..."
sync && echo 3 > /proc/sys/vm/drop_caches
echo 2 > /proc/sys/vm/drop_caches

# Trim unused memory from apps
for app in $(ls -d /proc/[0-9]*/); do
  awk '/VmSwap|VmRSS|VmSize/ { sum += $2 } END { print sum }' "$app"/status > /dev/null
  if [ $? -eq 0 ]; then
    mem_usage=$(cat "$app"/status | awk '/VmSwap|VmRSS|VmSize/ { sum += $2 } END { print sum }')
    if [ "$mem_usage" -lt 1048576 ]; then  # Trim apps using less than 1GB RAM
      echo 3 > "$app"/oom_score_adj
    fi
  fi
done


# --- Optional Tweaks (Require Custom Kernel) ---
ui_print "- Applying optional tweaks (custom kernel required)..."

# Increase zRAM size (if supported)
swapoff /dev/block/zram0
echo 1024M > /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon /dev/block/zram0

# Enable KSM (Kernel Samepage Merging)
echo 1 > /sys/kernel/mm/ksm/run
echo 1000 > /sys/kernel/mm/ksm/sleep_millisecs

# Set CPU governor to performance mode
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo "performance" > "$cpu"
done

# Optionally, set maximum CPU frequency (if supported)
# for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
#   echo "3300000" > "$cpu"  # Example: Set to 3.3 GHz
# done

# Set minimum active cores (e.g., to always keep 5 cores active)
echo 5 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

# Enable all cores (if needed)
for cpu in /sys/devices/system/cpu/cpu[0-7]; do
  echo 1 > "$cpu/online"
done

ui_print "- Done"