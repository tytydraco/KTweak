# KTweak
A no-nonsense kernel tweak script for Linux and Android systems, backed by evidence.

# Another "kernel optimizer"?
No. Well, yes. However, a "kernel optimizer" is a poor way to put it. KTweak performs kernel adjustments based on facts and evidence, unlike other optimizers with poorly written or heavily obfuscated code.

* [NFS Injector](https://github.com/Magisk-Modules-Grave/nfsinjector) uses closed source, compiled binaries with various typos in the README. It also provides a "pro" version that costs money.
* [MAGNETAR](https://github.com/Magisk-Modules-Grave/MAGNETAR) also uses closed source, compiled binaries. I'd love to say more about this, but I can't even find out what the module even does.
* [FDE.AI](https://forum.xda-developers.com/apps/magisk/beta-feradroid-engine-v0-19-ultimate-t3284421) also uses closed source, compiled binaries with a paid variant.
* [LKT](https://github.com/Magisk-Modules-Grave/legendary_kernel_tweaks/blob/master/common/system.prop) sets random nonsensical build.props that don't even exist.
* [ZeetaTweaks](https://t.me/zeetaaprojbot) is a clone of KTweak with the values changed. As of the V11 zip, it disables essential system services, deletes files permanently from /data/data, kills perfd (which is the userspace boosting daemon), disables SELinux, disables fsync, and various other detrimental changes.

# What's different about KTweak?
Unlike other "kernel optimizers", KTweak is:

* Entirely open source with no compiled components
* Concise, at less than 200 lines long
* Backed by benchmarks and evidence
* Designed by an experienced kernel developer
* Non-intrusive and completely systemless

# Benchmarks
The following benchmarks were performed on a OnePlus 7 Pro running the stock kernel provided by the OEM on Android 10. **KTweak sacrifices throughput for latency**, since latency correlates to UI / UX smoothness. This explains the slight regression with the scheduler throughput.


### Scheduler latency via `schbench` (lower is better)
- Stock:
`50.0th: 4052
75.0th: 14288
90.0th: 26848
95.0th: 32960
*99.0th: 45120
99.5th: 49856
99.9th: 59200
min=0, max=73600`

- KTweak:
`50.0th: 1054
75.0th: 1790
90.0th: 2628
95.0th: 3836
*99.0th: 8880
99.5th: 11472
99.9th: 18080
min=0, max=32781`

### Synthmark Latencymark (lower is better)
- Stock: 10 / 12
- KTweak: 4 / 4

### Scheduler throughput via `perf bench sched messaging` (lower is better)
- Stock: 0.331 seconds
- KTweak: 0.808 seconds

### Scheduler throughput via `perf bench sched pipe` (lower is better)
- Stock: 16.159 seconds
- KTweak: 18.599 seconds

# The Tweaks
Head over to the [script itself](ktweak) to learn what everything does. It is documented in the comments.

# Contact
You can find me on telegram at @tytydraco.
Feel free to email me at tylernij@gmail.com.

Join the releases channel at @ktweak, or the discussion channel at @ktweak_discussion.
