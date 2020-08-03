#!/system/bin/sh
# Written by Draco (tytydraco @ GitHub)

# Safely apply sysctl adjustment
ctl() {
	# Fetch the current key value
	local curval=`sysctl -e -n "$1"`

	# Bail out if sysctl key does not exist
	if [[ -z "$curval" ]]
	then
		echo "[!] Key $1 does not exist. Skipping."
		return 1
	fi

	# Bail out if sysctl is already set
	if [[ "$curval" == "$2" ]]
	then
		echo "[*] Key $1 is already set to $2. Skipping."
		return 0
	fi

	# Set the new value
	sysctl -w "$1"="$2" &> /dev/null

	# Bail out if write fails
	if [[ $? -ne 0 ]]
	then
		echo "[!] Failed to write $2 to $1. Skipping."
		return 1
	fi

	# Print new state
	echo "[*] $1: $curval --> $2"
}

# Safely write value to file
write() {
	# Bail out if file does not exist
	if [[ ! -f "$1" ]]
	then
		echo "[!] File $1 does not exist. Skipping."
		return 1
	fi

	# Fetch the current key value
	local curval=`cat "$1" 2> /dev/null`

	# Bail out if value is already set
	if [[ "$curval" == "$2" ]]
	then
		echo "[*] File $1 is already set to $2. Skipping."
		return 0
	fi

	# Write the new value
	echo "$2" > "$1"

	# Bail out if write fails
	if [[ $? -ne 0 ]]
	then
		echo "[!] Failed to write $2 to $1. Skipping."
		return 1
	fi

	# Print new state
	echo "[*] $1: $curval --> $2"
}

# Setup ZRAM to half of the available RAM
setup_zram() {
    memsize=`cat /proc/meminfo | grep "MemTotal" | awk '{print $2}'`
    halfmemsize=`echo "$(($memsize/2))"`

    swapoff /dev/block/zram0
    write /sys/block/zram0/reset 1
    write /sys/block/zram0/disksize "${halfmemsize}KB"
    mkswap /dev/block/zram0
    swapon /dev/block/zram0
}

# Print device information prior to execution
echo "[*] ----- Device Information -----"
# Kernel and device information
uname -a

# Scheduler feature check
[[ -f "/sys/kernel/debug/sched_features" ]] && echo "[*] Scheduler features exposed."

# CPU boost check
[[ -d "/sys/module/cpu_boost" ]] && echo "[*] CAF CPU boost detected."

# ZRAM support state
[[ -d "/sys/block/zram0" ]] && echo "[*] ZRAM supported."
echo "[*] ------------------------------"

# Wait 60s into boot before applying changes
echo "[*] Waiting for 60s of uptime."
while [[ `cat /proc/uptime | awk '{print $1}' | awk -F. '{print $1}'` -lt 60 ]]
do
	sleep 1
done
echo "[*] Done waiting."

# Kernel
ctl kernel.perf_cpu_time_max_percent 5
write /proc/sys/kernel/printk_devkmsg off
ctl kernel.randomize_va_space 0
ctl kernel.sched_autogroup_enabled 1
ctl kernel.sched_enable_thread_grouping 1
ctl kernel.sched_child_runs_first 1
ctl kernel.sched_downmigrate "40 40"
ctl kernel.sched_upmigrate "60 60"
ctl kernel.sched_group_downmigrate 40
ctl kernel.sched_group_upmigrate 60
ctl kernel.sched_tunable_scaling 0
ctl kernel.sched_latency_ns 10000000
ctl kernel.sched_min_granularity_ns 1000000
ctl kernel.sched_migration_cost_ns 1000000
ctl kernel.sched_min_task_util_for_boost 40
ctl kernel.sched_min_task_util_for_colocation 20
ctl kernel.sched_nr_migrate 64
ctl kernel.sched_rt_runtime_us 1000000
ctl kernel.sched_schedstats 0
ctl kernel.sched_wakeup_granularity_ns 5000000
ctl kernel.timer_migration 0

# Net
ctl net.ipv4.tcp_ecn 1
ctl net.ipv4.tcp_fastopen 3
ctl net.ipv4.tcp_slow_start_after_idle 0
ctl net.ipv4.tcp_syncookies 0
ctl net.ipv4.tcp_timestamps 0

# VM
ctl vm.dirty_background_ratio 3
ctl vm.dirty_ratio 30
ctl vm.dirty_expire_centisecs 1000
ctl vm.dirty_writeback_centisecs 0
ctl vm.extfrag_threshold 750
ctl vm.oom_dump_tasks 0
ctl vm.page-cluster 0
ctl vm.reap_mem_on_sigkill 1
ctl vm.stat_interval 10
ctl vm.swappiness 80
ctl vm.vfs_cache_pressure 200
ctl vm.watermark_scale_factor 100

# Scheduler features
if [[ -f "/sys/kernel/debug/sched_features" ]]
then
	write /sys/kernel/debug/sched_features NO_GENTLE_FAIR_SLEEPER
	write /sys/kernel/debug/sched_features NEXT_BUDDY
	write /sys/kernel/debug/sched_features NO_STRICT_SKIP_BUDDY
	write /sys/kernel/debug/sched_features NO_NONTASK_CAPACITY
	write /sys/kernel/debug/sched_features TTWU_QUEUE
fi

# CPU
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/
do
	write "${cpu}scaling_min_freq" `cat "${cpu}cpuinfo_min_freq"`
	write "${cpu}scaling_max_freq" `cat "${cpu}cpuinfo_max_freq"`

	avail_govs=`cat "${cpu}scaling_available_governors"`
	[[ "$avail_govs" == *"interactive"* ]] && write "${cpu}scaling_governor" interactive
	[[ "$avail_govs" == *"schedutil"* ]] && write "${cpu}scaling_governor" schedutil

	# Interactive-specific tweaks
	if [[ -d "${cpu}interactive" ]]
	then
		write "${cpu}interactive/go_hispeed_load" 80
		write "${cpu}interactive/hispeed_freq" `cat "${cpu}cpuinfo_max_freq"`
	fi

	# Schedutil-specific tweaks
	if [[ -d "${cpu}schedutil" ]]
	then
		write "${cpu}schedutil/up_rate_limit_us" 0
		write "${cpu}schedutil/down_rate_limit_us" 0
		write "${cpu}schedutil/hispeed_load" 80 
		write "${cpu}schedutil/hispeed_freq" `cat "${cpu}cpuinfo_max_freq"`
	fi
done

# CAF CPU boost
if [[ -d "/sys/module/cpu_boost" ]]
then
	write "/sys/module/cpu_boost/parameters/input_boost_freq" 1400000
	write "/sys/module/cpu_boost/parameters/input_boost_ms" 250
fi

# I/O
for queue in /sys/block/*/queue/
do
	write "${queue}iostats" 0
	write "${queue}read_ahead_kb" 0
	write "${queue}nr_requests" 512
	write "${queue}scheduler" noop
	write "${queue}scheduler" none
done

# ZRAM
[[ -d "/sys/block/zram0" ]] && setup_zram &

echo "[*] Done."
