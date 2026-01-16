# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Repository

This is a research/experimental fork of Ethereum focused on evaluating Ethereum performance.

**Base:** go-ethereum - blockchain for performance
**Research Focus:** evaluting throughput(tps), tail latencies(us) of transaction(p10,p20,p30,p40,p50,p60,p70,p75,p80,p90,p95,p99.p99.9,p99.99,p99.999), and # of block created based on time based(currently, i want to set 1200 seconds)
do not use mutex(lock) as possible, please record tail lantencies of each thread and aggreagate at the print phase of workload.


**Code Markers:** `//sj` (researcher implementations), `// FEAT` (feature additions)



## Benchmark Commands(Running Experiments)
I want to find the commands and setup for single node performance.


i like to print how many block are created during benchmark like below format:
Block generation during benchmark: slot 72 to 2930 = 2859 blocks

## Current result of benchmark (??)
