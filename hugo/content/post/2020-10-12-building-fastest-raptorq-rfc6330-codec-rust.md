---
title: Building the fastest RaptorQ (RFC6330) codec in Rust
author: Christopher Berner
type: post
date: 2020-10-12T02:11:47+00:00
url: /2020/10/12/building-fastest-raptorq-rfc6330-codec-rust/
categories:
  - programming

---
In my [last blog post](https://www.cberner.com/2019/03/30/raptorq-rfc6330-rust-optimization/), I wrote about learning Rust and implementing the RaptorQ (RFC6330) fountain code. I only optimized the library for handling small message sizes, since it was mainly a project to help me learn Rust. However, since releasing it, a number of people have started using the [raptorq crate](https://crates.io/crates/raptorq), so I've been working on making it more polished.

Shortly after open sourcing my initial implementation, someone [pointed out](https://github.com/cberner/raptorq/issues/8) that my library was slow for large numbers of symbols. RaptorQ encodes messages into a configurable number of symbols, and encoding more than ~200 symbols requires special data structures for doing sparse matrix math, which I hadn't bothered to implement. Never one to pass up a performance optimization challenge, I thought it would be fun to implement those, and along the way I discovered a bunch of optimizations that aren't documented in the RFC.

First off, I established a benchmark using 1280 byte symbols and 61MB messages split into 50000 symbols. 1280 bytes is a standard size used by other libraries, because it fits well into an IP packet. The proprietary Codornices library developed by [ICSI](http://www.icsi.berkeley.edu/icsi/) achieves [935Mbit/s on this benchmark](https://www.researchgate.net/publication/330937811_Performance_of_CodornicesRq_software_package_first_release), using similar hardware (they used a Ryzen 5 2600 @ 3.4GHz, and I used a Core i5-6600K @ 3.5GHz).

## v0.10.0: 206Mbit/s

After implementing sparse matrix routines to match the shape of the matrices used in the RaptorQ algorithm, and some straight forward optimizations -- like a fast path for rows with only a single non-zero element -- I was at about 20% of the fastest proprietary implementations. Not bad for a few days of work!

## v1.0.0: 220Mbit/s

For v1.0, I only made one additional optimization to the sparse FMA code path. Several people had reached out to me about using the raptorq crate in production, so I mostly worked on a few stability features for a 1.0 release, like a complete encode & decode test for every possible symbol count to ensure correctness.

## v1.1.0: 493Mbit/s

With the 1.0 release out, I went back to performance optimization. I spent a lot of time profiling my code, and at first couldn't find much more to optimize. The functions taking the most time were the core math routines, and those were already highly optimized with SIMD intrinsics. I figured the proprietary implementations must be using a bunch of special heuristics, or maybe a completely different matrix inverse algorithm. I decided to read through the RFC again, as well as the [original Raptor paper](http://www.ece.ubc.ca/~janm/Papers_RG/Shokrollahi_IT_June06.pdf), and see if I could figure them out myself. 

After many hours puzzling over the algorithm, I hit upon several optimizations which aren't noted in the RFC, and I [documented them](https://github.com/cberner/raptorq/blob/master/RFC6330_ERRATA.md) as a reference. Mostly these insights are sections of the matrix which are guaranteed to be binary valued instead of values in the full GF(256) range. This allows the use of bit packing to further accelerate the multiply & add functions, and it sped up performance to 360Mbit/s.

The second major insight was that cache had become the limiting factor. Almost all the data structures I used were O(1), but performance steadily degrades as symbol count increases:
```
symbol count = 10, encoded 127 MB in 0.555secs, throughput: 1844.9Mbit/s
symbol count = 100, encoded 127 MB in 0.606secs, throughput: 1688.8Mbit/s
symbol count = 250, encoded 127 MB in 0.926secs, throughput: 1104.7Mbit/s
symbol count = 500, encoded 127 MB in 0.892secs, throughput: 1144.1Mbit/s
symbol count = 1000, encoded 126 MB in 1.013secs, throughput: 1002.6Mbit/s
symbol count = 2000, encoded 126 MB in 1.174secs, throughput: 865.1Mbit/s
symbol count = 5000, encoded 122 MB in 1.353secs, throughput: 721.8Mbit/s
symbol count = 10000, encoded 122 MB in 1.768secs, throughput: 552.4Mbit/s
symbol count = 20000, encoded 122 MB in 2.754secs, throughput: 354.6Mbit/s
symbol count = 50000, encoded 122 MB in 4.342secs, throughput: 224.9Mbit/s
```

"perf stat -e instructions,cycles,cache-misses,cache-references" makes it obvious what's going on:

```
symbol count = 100, encoded 127 MB in 0.594secs, throughput: 1723.0Mbit/s

Performance counter stats for 'cargo bench ...':
  5,254,632,204      instructions          #    2.23  insn per cycle         
  2,353,214,171      cycles                                                  
      1,606,739      cache-misses          #    1.835 % of all cache refs    
     87,562,092      cache-references
```

With 100 symbols (above) the CPU is executing 2.23 instructions per cycle and getting > 98% cache hits, which is great! However, with 50000 symbols (below) the story is completely different. IPC is only 1.22, and cache misses are at 43%.

```
symbol count = 50000, encoded 122 MB in 4.280secs, throughput: 228.2Mbit/s

Performance counter stats for 'cargo bench ...':
  20,323,685,241      instructions         #    1.22  insn per cycle         
  16,717,417,896      cycles                                                 
     478,019,226      cache-misses         #   43.244 % of all cache refs    
   1,105,393,476      cache-references
```

To further improve performance the key was reducing the size of the working set. Encoding 50000 symbols required 93MB of memory to store the matrix and associated data structures, which is far too large to fit in L2 cache. After a lot of optimization I was able to reduce this to 11MB, which still doesn't entirely fit in L2, but was enough to increase IPC to > 1.7.

The two main optimizations I did were both further bit packing. For example, I had previously stored sparse elements as `(index, value)` tuples with the type `(usize, u8)`. Due to alignment, this type actually takes 16 bytes on a 64-bit platform. Only 3 bytes are required though, because the index has a maximum value of 56403, and in fact, after some further analysis I was able to compact it down to 2 bytes because the values in that section of the matrix are binary, so I could store only the index and make zeros implicit.

Altogether this improved performance to 493Mbit/s, which is within a factor of 2 of the fastest proprietary implementation I know of!

If you're an expert in finite field math and know of other ways to optimize this matrix inversion, [hit me up](https://github.com/cberner/raptorq/issues)! I'd love to collaborate on making this the fastest RaptorQ implementation in the world.
