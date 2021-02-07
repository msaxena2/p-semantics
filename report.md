---
title: A rewriting semantics for the P language
author:
 - Manasvi Saxena (nishant2@illinois.edu)
 - Nishant Rodrigues (msaxena2@illinois.edu)
---


Writing asynchronous programs and protocols is difficult, and fraught with
pitfalls not typicall found in synchronous programs such as race conditions and
deadlocks. Using a general purpose langauge such as C or Python does not let us
easily detect such issues. We therefore turn to high-level languages that allows
model checking for safety and liveness properties. P is such a high-level
language. It is a domain-specific language for writing asynchronous event driven
code. This code may then be compiled into an executable, or be used for model
checking.

The P language may be viewed as a process calculus. 
With respect to functionality, it is quite similar to $\pi$-caclulus,
although with built-in constructs for imperative control flow operators, 
buffers, actors and states.

- Why is a formal semantics needed?

Our Implementation

- Rules vs Equations

Future Work

- Complete Semantics
- Use for model checking
