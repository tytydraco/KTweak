# ktweak
A no-nonsense kernel tweak script for Linux and Android systems, backed with evidence.

# Magisk Module
The Magisk Module portion of this script is located in the `magisk-module` branch.

# Another "kernel optimizer"?
No. Well, yes. However, a "kernel optimizer" is a poor way to put it. KTweak performs kernel adjustments based on facts and evidence, unlike other optimizers with poorly written or heavily obfuscated code. For example:

* [LSpeed](https://github.com/Magisk-Modules-Grave/lspeed/blob/master/system/etc/lspeed/binary/main_function#L3896) is almost 4000 lines long; completely unnecessary.
* [NFS Injector](https://github.com/Magisk-Modules-Grave/nfsinjector/tree/master/system/etc/nfs/arm) uses compiled binaries that are closed source... yuck. Not to mention the typos in the README. This one is hard to look at.
* [LKT](https://github.com/Magisk-Modules-Grave/legendary_kernel_tweaks/blob/master/common/system.prop) sets random nonsensical build.props that likely don't even exist.
* [MAGNETAR](https://github.com/Magisk-Modules-Grave/MAGNETAR) uses (you guessed it) compiled binaries that install themselves to your */system/etc/ directory* (???). Great idea, install an external closed source, compiled binary to the system partition.

Need I go on?

# What's different about KTweak?
Unlike other "kernel optimizers", KTweak is:

* Concise, at around 200 lines long,
* Entirely open source with no compiled components,
* Backed by logic and evidence,
* Designed by an experienced kernel developer,
* Non-intrusive, being completely systemless.

# Benchmarks
The following benchmarks were performed on a OnePlus 7 Pro running the stock kernel provided by the OEM on Android 10.

### `hackbench -pTl 4000` (lower is better)
* Without KTweak: ~20-50 seconds on average
* With KTweak: ~4-6 seconds on average

### `perf bench mem memcpy` (lower is better) (average of 50 iters)
* Without KTweak: 14.01 ms
* With KTweak: 10.40 ms

### `synthmark` (voicemark) (higher is better)
* Without KTweak: 374.94
* With KTweak: 383.556

### `synthmark` (latencymark little) (lower is better)
* Without KTweak: 10
* With KTweak: 10

### `synthmark` (latencymark big) (lower is better)
* Without KTweak: 12
* With KTweak: 10

# The Tweaks
In order to remain genuine, I have commited to explaining each and every kernel tweak that KTweak applies. Grab your coffee, this could take a while.

### kernel.perf_cpu_time_max_percent: 25 --> 5
This is the **maximum** CPU time long perf event processing can take as a percentage. If this percentage is exceeded (meaning perf event processing used too much CPU time), the polling rate is throttled. This is reduced from 25% to 5%. We can afford inaccuracies with perf events in exchange for more time that a foreground task can use.

### kernel.sched_autogroup_enabled: 0 --> 1
The Linux Kernel scheduler (CFS) distributes timeslices to each active task. For example, if the scheduling period is 10ms, and there are 5 tasks running, CFS will give each task 2ms of runtime for that scheduling cycle. However, this means that a SCHED_OTHER task may compete with a SCHED_FIFO task. Autogrouping groups task groups together during scheduling. For example, if the scheduling period is 10ms, and there are 6 SCHED_OTHER tasks running and 4 SCHED_FIFO tasks running, the SCHED_OTHER tasks will get 50% of the runtime and the SCHED_FIFO tasks will get the other 50%. For each task group, the timeslices are once again divided. The SCHED_FIFO tasks will get 12.5% runtime and the SCHED_OTHER tasks will get ~8.3% runtime. This usually offers better interactivity on multithreaded platforms.
See scheduling priority documentation: https://man7.org/linux/man-pages/man7/sched.7.html
See autogrouping off: https://www.youtube.com/watch?v=uk70SeGA7pg
See autogrouping on: https://www.youtube.com/watch?v=prxInRdaNfc

### kernel.sched_enable_thread_grouping: 0 --> 1
To my knowledge using the limited documentation of this tunable, this is basically autogrouping for thread groups.

### kernel.sched_child_runs_first: 0 --> 1
When forking a child process from the parent, execute the child process before the parent process. This usually shaves down some latency on task initializations, since most of the time the child process is doing some form of heavy lifting.

### kernel.sched_tunable_scaling: 0
This is more of a precaution than anything. Since the next few tunables will be scheduler timing related, we don't want the scheduler to scale our values for multiple CPUs, as we will be providing CPU-agnostic values.

### kernel.sched_latency_ns: 5000000 (5ms)
Set the default scheduling period to 5ms. Reduce the maximum scheduling period to reduce overall scheduling latency.

### kernel.sched_min_granularity_ns: 500000 (0.5ms)
Set the minimum task scheduling period to 0.5ms. With kernel.sched_latency_ns set to 5ms, this means that 10 active tasks may execute within the 10ms scheduling period before we exceed it.

### kernel.sched_wakeup_granularity_ns: 1000000 (1ms)
Require tasks to be running for at least 1ms longer than the waiting task before preemption can happen. Reducing this value to 1ms reduces wakeup preemption latencies by up to 50% at a 50th percentile and around 10% for higher percentiles. Hackbench scores suffer if this value is reduced too low.

### kernel.sched_migration_cost_ns: 500000 (0.5ms) --> 1000000 (1ms)
Increase the time that a task is considered to be cache hot. According to RedHat, increasing this tunable reduces the number of task migrations. This should reduce time spent balancing tasks and increase per-task performance.
See RedHat: https://www.redhat.com/files/summit/session-assets/2018/Performance-analysis-and-tuning-of-Red-Hat-Enterprise-Linux-Part-1.pdf

### kernel.sched_min_task_util_for_colocation: 35 --> 0
This value determines when top-app tasks (which are of greater priority than background tasks) can be sched_boosted. Set this value to zero to allow top-app tasks to always be upmigrated if the sched_{up,down}migrate values are met.

### kernel.sched_nr_migrate: 32 --> 16
Reduce the maximum number of sched entities that can migrate in a single scheduling period. Reducing this value reduces realtime task latency at the cost of SCHED_OTHER throughput.

### kernel.sched_schedstats: 1 --> 0
Disable scheduler statistics accounting. This is just for debugging, but it adds overhead.

### vm.dirty_background_ratio: 5 --> 10
Start writing back dirty pages (pages that have been modified but not yet written to the disk) asynchronously at 10% memory dirtied instead of 5%. Writing dirty pages back too early can be inefficient and overutilize the storage device.

### vm.dirty_ratio: 20 --> 30
This tunable is the same as the former, but it is the ceiling for **synchronous** dirty writeback, meaning all I/O will stall until all dirty pages are written out to the disk. We usually won't need to worry about hitting this value, as the background writeback can catch up before we reach 20% memory dirtied. But as a precaution (i.e. heavy file transfers), increase this value to a 30% ceiling to prevent visible system stalls. We are sacrificing available memory in exchange for a reduced change of a brief system stall.

### vm.dirty_expire_centisecs: 300 (3s) --> 3000 (30s)
This is the longest that dirty pages can remain in the system before they are forcefully written out to the disk. By increasing this value, we can allow the dirty background writeback to take its time asynchronously, and avoid unnecessary writebacks that can clog the flusher thread.

### vm.dirty_writeback_centisecs: 500 (5s) --> 3000 (30s)
Do background writeback via flusher threads less often to reduce occasional overhead.

### vm.page-cluster: 3 --> 0
Disable reading additional pages from the swap device (in most cases, ZRAM). This is the same philosophy as disabling readahead.

### vm.reap_mem_on_sigkill: 0 --> 1
When we kill a task, clean its memory footprint to free up whatever amount of RAM it was consuming.

### vm.stat_interval: 1 --> 10
Update /proc/stat information every 10 seconds instead of every second, reducing jitter on loaded systems.

### vm.swappiness: 100
This is the default on many recent devices, but legacy devices may still be using 60. Swap to ZRAM at a fair rate.

### vm.vfs_cache_pressure: 100 --> 60
This tunable controls the kernel's tendency to reclaim inodes and dentries over page cache. Inodes and dentries are information about file metadata and directory structures, while page cache is the actual cached contents of a file. By reducing this value, we can cache file structure information for improved performance.

### Next Buddy
By scheduling the last woken task first, we can increase cache locality since that task is likely to touch the same data as before.

### No Strict Skip Buddy
Usually, the scheduler will always choose to skip tasks that call `yield()`. However, these yeilding tasks may be of higher importance than the last or next buddy that are available. Do not always skip the skip buddy if we don't have to.

### No Nontask Capacity
The scheduler decrements the perceived CPU capacity that longer the CPU has been idle for. This means that an idle CPU may be skipped during task placement, and a task can be grouped with a busier CPU. Disable this to improve task start latency.

### TTWU Queue
Allow the scheduler to place tasks on their origin CPU, increasing cache locality if the CPU is non-local (i.e. a cache hit would definitely have been missed).

### Governor Tweaks
* {up_,down_}rate_limit_us / min_sample_time: 0 --> 5000: Only adjust frequencies once per scheduling cycle to reduce jitter or stutter caused by unrealistic frequency scaling.
* hispeed_load / go_hispeed_load: 90: Jump to a higher frequency if we are approaching the end of the frequency list, where a task may begin to starve or begin to stutter.
* hispeed_freq: <max>: Set the "higher freq" (referencing hispeed_load) to the maximum frequency available to take advantage of [Race-To-Idle](https://lwn.net/Articles/281629/).

### I/O
* iostats: 1 --> 0: Disable I/O statistics accounting, which adds overhead.
* readahead: 128 --> 0: Reduce readahead, which is intended for disks with long seek times (HDD), whereas mobile devices use flash storage with zero seek time. In testing, this improves IOPS by up to 4% for reads and 2% for random reads and random writes.
* nr_requests: 128 --> 64: Reduce I/O latencies slightly by reducing the maximum queue depth.
* cfq / kyber: Use a scheduler with balanced scheduling to reduce I/O latencies, which is essential for fast flash storage (eMMC & UFS).

### ZRAM
ZRAM reduces disk wear by reducing disk writes, and also increases cache locality by allowing more data to fit in RAM at once. KTweak configures ZRAM to take up at most half of the available RAM on the system, which is a good ratio of RAM to ZRAM for a mobile device.

# Other Notes
You should know that on Android devices, KTweak applies after init finishes + Android mounts + 120 seconds in order to prevent Android's init from overwriting any values.

# Contact
You can find me on telegram at @tytydraco.
Feel free to email me at tylernij@gmail.com.
