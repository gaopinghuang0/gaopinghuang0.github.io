---
layout: post
title: "Interesting Algorithms and Data Structures"
author: "Gaoping Huang"
tags: Algorithm
use_math: false
use_bootstrap: false
---


## Algorithms
1. Rho-shaped linked-list. 


2. Heap management in OS.

Use a linked-list called `freeList` to represent all free segments. Each segment has one field to store its data size, and the address of next segment. When `alloc`, find the best-fit or first-fit segment (segment.size >= required_size+2). Shrink the size of curr segment after alloc. When `dealloc`, append this block to the tail of `freeList`.


## Data Structues
1. Segment Tree. https://www.geeksforgeeks.org/segment-tree-set-1-sum-of-given-range/
Questions:

