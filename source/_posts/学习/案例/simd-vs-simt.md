---
title: GPU 体系架构之争：SIMD 和 SIMT
date: 2025-02-07 12:07:21
categories: 案例
tags:
  - 案例
  - 笔记
  - GPU
  - 并行计算
comments: true
toc: true
donate: true
share: true
---

# GPU 体系架构之争：SIMD 和 SIMT

- BV18WcNedETb
- https://www.bilibili.com/video/BV18WcNedETb

### SIMD 和 SIMT 的布局区别（以 8 线程 8 单元硬件为例）

![布局](/imgs/simd-vs-simt/layout.jpg)

- SIMD：2 个线程，每个线程 4 个运算单元。
- SIMT：8 个线程，每个线程 1 个运算单元。

### 缺省向量

如果只用到向量的 3 个分量（vec3），而不用第四个分量，那么

![缺省向量](/imgs/simd-vs-simt/demo-vec3.jpg)

- SIMD 架构会有运算单元空转的情况发生，因为它一个线程必须霸占 4 个计算单元，但却只有 3 个分量需要计算，最终花费 4 个周期完成运算。
- 而 SIMT 架构每次都处理 8 个线程的同一个分量，只需 3 个周期完成运算。

### 条件分支

![条件分支-代码](/imgs/simd-vs-simt/demo-branch-1.jpg)
![条件分支-分析](/imgs/simd-vs-simt/demo-branch-2.jpg)

每个线程运行不同的任务。这种情况下，由于条件分支的影响，多线程无法合并运算（GPU 核判断到不同线程的程序计数器不同，说明发生了条件分支，因此不会让多线程同时运行，即使都是加法运算，GPU 也没有这个进一步的推理能力（也不需要这种推理能力，否则运算性能大打折扣））。

- 假设任务是：8 个线程，8 个向量，每个向量都是 4 分量向量的运算。总共要完成 `8 * 4 = 32` 个单元运算。
- SIMD 由于硬件线程只有两个，每个线程霸占 4 个单元，可以在一个周期完成一个线程的向量运算（4 分量向量）。总共要花费 `32 / 4 = 8` 个周期。
- SIMD 则因为 8 个线程均分了 8 个单元，每个周期又只能运行一个线程，因此每个周期只能运算 1 个向量的 1 个分量，总共需要 `32 / 1 = 32` 个周期。
