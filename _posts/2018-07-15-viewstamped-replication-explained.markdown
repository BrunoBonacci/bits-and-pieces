---
layout:     post
title:      Viewstamped Replication expleined
date:       2018-07-15 00:00:00
categories: [distributed systems, consensus algorithm]
tags:       [Papers]

author:
  name:  Bruno Bonacci
  image: bb.png
---

Viewstamped Replication (*VR* for short) is one of the earliest
consensus algorithm for distributed systems, it is designed around the
replication of state machine's operation log and it can be efficiently
implemented for modern systems. The revisited paper offers a number of
improvements on the algorithm from the original paper which both:
simplifies the algorithm and makes more suitable for high volume
systems. The original paper was published in 1988 which is ten years
before the [Paxos
algorithm](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf)
was published.

I will explain how the protocol works in detail covering as well a
number of optimizations which are described in the papers. The
"revisited" version offers a simplified version of the protocol with
improvements which were made by the authors in later works published
after the original paper. Therefore most of the content here will be
driven from the more 2012 paper.


![viewstamped replication](../images/vr-paper/PWL-ViewstampedReplication.001.png)

  * Paper links:
    - *Viewstamped Replication: A New Primary Copy method to Support Highly-Available Distributed Systems, B. Oki, B. Liskov, (1988)* <br/>
    http://pmg.csail.mit.edu/papers/vr.pdf
    - *Viewstamped Replication Revisited, B. Liskov, J.Cowling (2012)* <br/>
    http://pmg.csail.mit.edu/papers/vr-revisited.pdf

## What is "Viewstamped Replication"?

It is a replication protocol. It aims to guarantee consistent view
over replicated data.  It is a “consensus algorithm”. To provide
consistent view over replicated data, replicas must agree on
replicated state.

It is designed to be a pluggable protocol which works on the
communication layer between your clients and the servers as well as
between server themselves.  The idea is that you can take a non
distributed system and by using this replication protocol turn a
single node system into a high-available, fault tolerant distributed
system.

**To achieve fault-tolerance, the system must introduce redundancy in
time and space**. *Redundancy in time* is to combat the unreliability
of the network. Messages can be dropped, reordered or arbitrarily
delayed, therefore protocol must account for it and allow requests to
be replayed if necessary without causing duplication in the system.
*Redundancy in space* is generally achieved via adding redundant
copies in different machine with different fault-domain isolation,
the aim is to recover from a node failure, whether is a system crash
or a hardware failure, the system must be able to continue normal
operation within certain limits.

Together, the *redundancy in time and space* provide the ability to
tolerate and recover from temporary network partitions, systems
crashes, hardware failure and a wide range of network related issues.

However the system can only tolerate a number of failures depending on
the cluster (or **ensemble** size). In particular to tolerate 𝑓
failures it is required a ensemble size of `2𝑓 + 1`. The type of
failures that the protocol can tolerate are **non Byzantine failures** [^1]
which means that all the nodes in the ensemble will be either in a
working state, or in a failed state or simply isolated. However, every
node in the system will not deviate from the protocol and it will not
lie about its state. Therefore, if the system must be able to tolerate
one node to be unresponsive, then the minimum ensemble size is 3
nodes. If the system must be able to tolerate 2 concurrent failures,
then the minimum size of the cluster required is 5 nodes, and so
on. `𝑓 + 1` nodes is called **quorum**. It is not possible to create a
quorum with less than 3 nodes, therefore the minimum ensemble size is
3.

---

Links and resources:

   [^1]: [The Byzantine Generals Problem, Lamport](https://www.microsoft.com/en-us/research/publication/byzantine-generals-problem/)
