---
title: Debugging JVM Safepoint Pauses
author: Christopher Berner
type: post
date: 2015-05-24T17:48:36+00:00
url: /2015/05/24/debugging-jvm-safepoint-pauses/
categories:
  - Uncategorized

---
I recently spent a bunch of time investigating why a Java application was spending a significant amount of time paused, even when garbage collection cycles were only taking ~200ms. The issue turned out to be other safepoints.

For those that don't know, the VM uses safepoints to perform a variety of internal operations, and they involve pausing every Java thread. Garbage collection is the most well known, but many other operations such as deoptimization, and revoking biased locks require a safepoint as well. [Alexey Ragozin][1] has a good explanation of safepoints and points to some VM flags that are useful for debugging safepoint issue.

```text
-XX:+PrintGCApplicationStoppedTime
-XX:+PrintSafepointStatistics
-XX:PrintSafepointStatisticsCount=1
```

However, he didn't explain how to interpret the output, so I dug into the source code to find out what the logging meant. The output on safepoint statistics is shown below. (note: I split the line in half to make it easier to read)

```text
vmop  [threads: total initially_running wait_to_block]
10.526: RevokeBias  [154          0              3      ]
```

The first part tells you what operation is being performed "RevokeBias" in this case, which means that a biased lock is being revoked. The next three numbers are the total number of threads, the number that were running and contributed to the "spin" time, and the number of threads which contributed to the "block" time (shown below).

```text
[time: spin block sync   cleanup vmop] page_trap_count
[      0    3471 3583    531     5342]  0
```

This part is the most interesting. It tells us how long (in milliseconds) the VM spun waiting for threads to reach the safepoint. Second, it lists how long it waited for threads to block. The third number is the total time waiting for threads to reach the safepoint (spin + block + some other time). Fourth, is the time spent in internal VM cleanup activities. Fifth, is the time spent in the operation itself (RevokeBias in this case).

In this example, we can see pretty clearly that the pause was caused by 3.5secs spent waiting for threads to block, and then an additional 5secs revoking the biased lock.

 [1]: http://blog.ragozin.info/2012/10/safepoints-in-hotspot-jvm.html
