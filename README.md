# KTweak
A no-nonsense kernel tweak script for Linux and Android systems, backed by evidence.

# Another "kernel optimizer"?
No. Well, yes. However, a "kernel optimizer" is a poor way to put it. KTweak performs kernel adjustments based on facts and evidence, unlike other optimizers with poorly written or heavily obfuscated code.

* [NFS Injector](https://github.com/Magisk-Modules-Grave/nfsinjector) uses closed source, compiled binaries with various typos in the README. It also provides a "pro" version that costs money.
* [MAGNETAR](https://github.com/Magisk-Modules-Grave/MAGNETAR) also uses closed source, compiled binaries. I'd love to say more about this, but I can't even find out what the module even does.
* [FDE.AI](https://forum.xda-developers.com/apps/magisk/beta-feradroid-engine-v0-19-ultimate-t3284421) also uses closed source, compiled binaries. It also claims to use machine learning to provide real-time optimization. However, the binary does not "learn", it simply collects statistics and makes changes. This is called an algorithm, and is **not** an artifical intelligence. This also has a paid variant.
* [LKT](https://github.com/Magisk-Modules-Grave/legendary_kernel_tweaks/blob/master/common/system.prop) sets random nonsensical build.props that don't even exist.
* [NUKED](https://forum.xda-developers.com/apps/magisk/module-tool-atteryerformancerivacy-t4131715) is yet another closed source, compiled binary. It makes a lot of claims that it cannot back up. Under further investigation, it was discovered that the binaries are heavily obfuscated.
* [ZeetaTweaks](https://forum.xda-developers.com/showthread.php?t=1353903) is a clone of KTweak with the values changed. As of the V11 zip, it disables essential system services, deletes files permanently from /data/data, kills perfd (which is the userspace boosting daemon), disables SELinux, disables fsync, and various other detrimental changes.

# What's different about KTweak?
Unlike other "kernel optimizers", KTweak is:

* Entirely open source with no compiled components
* Concise, at less than 200 lines long
* Backed by benchmarks and evidence
* Designed by an experienced kernel developer
* Non-intrusive and completely systemless

# Benchmarks
The following benchmarks were performed on a OnePlus 7 Pro running the stock kernel provided by the OEM on Android 10.

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
`50.0th: 2532
75.0th: 11248
90.0th: 22560
95.0th: 29984
*99.0th: 39232
99.5th: 42560
99.9th: 49088
min=0, max=63731`

### Scheduler throughput via `perf bench sched messaging` (lower is better)
- Stock: 0.331 seconds
- KTweak: 0.808 seconds

### Scheduler throughput via `perf bench sched pipe` (lower is better)
- Stock: 16.159 seconds
- KTweak: 18.599 seconds

KTweak sacrifices throughput for latency, since latency correlates to UI / UX smoothness. This explains the slight regression with the scheduler throughput.

# The Tweaks
Head over to the [script itself](ktweak) to learn what everything does. It is documented in the comments.

# Other Notes
You should know that on Android devices, KTweak applies after init finishes + Android mounts + 120 seconds in order to prevent Android's init from overwriting any values.

# Contact
You can find me on telegram at @tytydraco.
Feel free to email me at tylernij@gmail.com.

Join the releases channel at @ktweak, or the discussion channel at @ktweak_discussion.
