# ktweak
A no-nonsense kernel tweak script for Android devices, backed with evidence.

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

### kernel.sched_downmigrate: 50    50
Do not allow tasks to migrate back down to a lower-power CPU until the estimated CPU utilization would go below 20% on said CPU. This means tasks will stay on higher-performance CPUs for longer than usual.

### kernel.sched_upmigrate: 80    80
Similar to the previous tunable, do not allow tasks to migrate to the higher-performance CPUs unless the utilization goes above 80%.

### kernel.sched_group_downmigrate: 50
The same as kernel.sched_downmigrate, except for whole task groups.

### kernel.sched_group_upmigrate: 80
The same as kernel.sched_upmigrate, except for whole task groups.

### kernel.sched_tunable_scaling: 0
This is more of a precaution than anything. Since the next few tunables will be scheduler timing related, we don't want the scheduler to scale our values for multiple CPUs, as we will be providing CPU-agnostic values.

### kernel.sched_latency_ns: 10000000 (10ms)
Set the default scheduling period to 10ms. If this value is set too low, the scheduler will switch contexts too often, spending more time internally than executing the waiting tasks.

### kernel.sched_min_granularity_ns: 2500000 (2.5ms)
Set the minimum task scheduling period to 2.5ms. With kernel.sched_latency_ns set to 2.5ms, this means that 4 active tasks may execute within the 10ms scheduling period before we exceed it. Originally, this value was set to 1ms. After benchmarking using `hackbench -pl 8000`, it was determined that a higher value reduces hackbench times significantly. The tradeoff is scheduling latency.

### kernel.sched_migration_cost_ns: 500000 (0.5ms) --> 1000000 (1ms)
Increase the time that a task is considered to be cache hot. According to RedHat, increasing this tunable reduces the number of task migrations. This should reduce time spent balancing tasks and increase per-task performance.
See RedHat: https://www.redhat.com/files/summit/session-assets/2018/Performance-analysis-and-tuning-of-Red-Hat-Enterprise-Linux-Part-1.pdf

### kernel.sched_min_task_util_for_boost: 35
This value effects if tasks should be migrated to a higher performant CPU if it's utilization is above this amount (during sched_boost). Allow tasks to be migrated upwards if the user is triggering a touch boost and the task is above 35% utilization.

### kernel.sched_min_task_util_for_colocation: 25
This value is the same as the former, except it occurs only for top-app tasks (which are of greater priority than background tasks). Lower this value a bit to use big clusters more for top-app tasks.

### kernel.sched_min_task_util_for_boost_colocation: 35
This is the same as kernel.sched_min_task_util_for_boost for older kernel versions.

### kernel.sched_nr_migrate: 32 --> 128
When migrating tasks between CPUs, allow the scheduler to migrate twice as many as usual. This should increase scheduling latency marginally, but increase the performance of SCHED_OTHER tasks. In testing, `cyclictest` reported a 2 microsecond increase in average latency, an a **decrease** in maximum latency of SCHED_FIFO tasks.

### kernel.sched_schedstats: 1 --> 0
Disable scheduler statistics accounting. This is just for debugging, but it adds overhead.

### kernel.sched_wakeup_granularity_ns: 1000000 (1ms) --> 10000000 (10ms)
Require the current task to be surpassing the new task in vmruntime by 10ms instead of 1ms before preemption occurs. In testing, `hackbench -pl 8000` times were reduced by ~94% (NOT a typo).

### vm.dirty_background_ratio: 5 --> 10
Start writing back dirty pages (pages that have been modified but not yet written to the disk) asynchronously at 10% memory dirtied instead of 5%. Writing dirty pages back too early can be inefficient and overutilize the storage device.

### vm.dirty_ratio: 20 --> 30
This tunable is the same as the former, but it is the ceiling for **synchronous** dirty writeback, meaning all I/O will stall until all dirty pages are written out to the disk. We usually won't need to worry about hitting this value, as the background writeback can catch up before we reach 20% memory dirtied. But as a precaution (i.e. heavy file transfers), increase this value to a 30% ceiling to prevent visible system stalls. We are sacrificing available memory in exchange for a reduced change of a brief system stall.

### vm.dirty_expire_centisecs: 300 (3s) --> 1000 (10s)
This is the longest that dirty pages can remain in the system before they are forcefully written out to the disk. By increasing this value, we can allow the dirty background writeback to take its time asynchronously, and avoid unnecessary writebacks that can clog the flusher thread.

### vm.dirty_writeback_centisecs: 500 (5s) --> 0 (0s)
Do not periodically writeback data every 5 seconds. Instead, leave it to the dirty background writeback to wake up when the dirty memory of the system hits 10%. This allows the dirty pages to stay in memory for longer, possibly increasing cache locality as the page cache is still available in memory.

### vm.extfrag_threshold: 500 --> 750
Compact memory more often, even if the memory allocation was estimated to be due to a low-memory status. This lets us put more data into RAM at the expense of running compation more often. This is a worthy tradeoff, as it reduces memory fragmentation, which is incredibly important for ZRAM.

### vm.oom_dump_tasks: 1 --> 0
Do not dump debug information when (or if) we run out of memory. If we have a lot of tasks running, and are OOMing often, then this overhead can add up.

### vm.page-cluster: 3 --> 0
Disable reading additional pages from the swap device (in most cases, ZRAM). This is the same philosophy as disabling readahead.

### vm.reap_mem_on_sigkill: 0 --> 1
When we kill a task, clean its memory footprint to free up whatever amount of RAM it was consuming.

### vm.stat_interval: 1 --> 10
Update /proc/stat information every 10 seconds instead of every second, reducing jitter on loaded systems.

### vm.swappiness: 100
This is the default on many recent devices, but legacy devices may still be using 60. Swap to ZRAM at a fair rate.

### vm.vfs_cache_pressure: 100 --> 200
This tunable controls the kernel's tendency to reclaim inodes and dentries over page cache. Inodes and dentries are information about file metadata and directory structures, while page cache is the actual cached contents of a file. By increasing this value to 200, we tell the kernel to prefer claiming inodes and dentries over the page cache, increasing the chance of a cache hit when referencing recently used data, while not polluting the RAM with less-important information.

### Next Buddy
By scheduling the last woken task first, we can increase cache locality since that task is likely to touch the same data as before.

### No Strict Skip Buddy
Usually, the scheduler will always choose to skip tasks that call `yield()`. However, these yeilding tasks may be of higher importance than the last or next buddy that are available. Do not always skip the skip buddy if we don't have to.

### No Nontask Capacity
The scheduler decrements the perceived CPU capacity that longer the CPU has been idle for. This means that an idle CPU may be skipped during task placement, and a task can be grouped with a busier CPU. Disable this to improve task start latency.

### TTWU Queue
Allow the scheduler to place tasks on their origin CPU, increasing cache locality if the CPU is non-local (i.e. a cache hit would definitely have been missed).

### Governor Tweaks
* hispeed_load: 90 --> 80: Jump to a higher frequency if we are approaching the end of the frequency list, where a task may begin to starve or begin to stutter.
* hispeed_freq: <max>: Set the "higher freq" (referencing hispeed_load) to the maximum frequency available to take advantage of [Race-To-Idle](https://lwn.net/Articles/281629/).

### CAF CPU Boost Tweaks
* input_boost_freq: 1.4 GHz (closest freq) as a generic, universal boost frequency to the little cluster.
* input_boost_ms: 250 ms, not consuming too much power but boosting for important, interactive events such as clicking on things.

### I/O
* iostats: 1 --> 0: Disable I/O statistics accounting, which adds overhead.
* readahead: 128 --> 64: Reduce readahead, which is intended for disks with long seek times (HDD), whereas mobile devices use flash storage with zero seek time.
* nr_requests: 128 --> 64: Reduce I/O latencies slightly by reducing the maximum queue depth.
* cfq / kyber: Use a scheduler with balanced scheduling to reduce I/O latencies, which is essential for fast flash storage (eMMC & UFS).

# Other Notes
You should know that KTweak applies after init finishes + 90 seconds in order to prevent Android's init from overwriting any values.

# Contact
You can find me on telegram at @tytydraco.
Feel free to email me at tylernij@gmail.com.
