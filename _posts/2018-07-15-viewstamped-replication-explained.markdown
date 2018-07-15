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
between servers themselves.  The idea is that you can take a non
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
failures it requires an ensemble of `2𝑓 + 1` replicas. The type of
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

TODO: add section with redis example which explain VR is a
      communication wrapper.


## Replicated State Machines

Viewstamped Replication is based on the *State Machine Replication* concept.
A State Machine has an *initial state* and a *operation log*. The idea is
that if you apply the ordered set of operation in the operation log to the
initial state you will end up always with the same final state, *given that
all the operations in the operation log are **deterministic***.

Therefore, if we replicate the initial state and the operation log into
other machines and repeat the same operations the final state on all the
machines will be same.

![Replicated State Machines](../images/vr-paper/vr-replicated-stm.gif)

It is crucial that the *order of operations is preserved* as
operations are not required to be commutative. Additionally *all
sources of indeterminism must be eliminated* before the operation are
added to the operation log.  For example if you have a operation which
generate a unique random id, the primary replica will need to generate
the random id and then add an operation in the log which already
contains the generated number such that when the replicas apply the
operation won't need to generate the random unique id themselves which
will cause the replica state to diverge.

The objective of Viewstamped Replication is to ensure that there is a
strictly consistent view on the operation log. In other words is
ensures that all replicas agree on which operations are in the log.


## Anatomy of a Replica

The ensemble or cluster is made of replica nodes. Each replica is
composed of the following parts.

![anatomy of a replica](../images/vr-paper/anatomy.png)

The operation log (`op-log`) is a (mostly) append only sequence of
operations.  Operations are applied against the current state which
could be external to the replica itself. Operations must be
*deterministic* which means that every application of the same
operation with the same arguments must produce the same
result. Additionally, if the operations produce side effect or write
to an external system you have to ensure the operation is applied only
once by the use of transactional support or by making operation
*idempotent* so that multiple application of the same operation won't
produce duplication in the target system.  Each operation in the
operation-log has a positional identifier which is the
`operation-number` which is a monotonically increasing
number.

The last inserted operation is the high water mark for the operation
log and it is recorded as the `op-num` which is a monotonically
increasing number as well. It identifies which operation has been
already received and it is used in parts of the protocol.

Operations in the `op-log` are appended first, then shared with other
replicas and once there is a confirmation that enough replicas have
received the operation then it is actually executed. We will see how
this process works in mode details later. The `commit-num` represents
the number of the last operation which was executed in the replica. It
also implies that all the previous operations have been executed as
well. `commit-num` is a monotonically increasing number.

The *view-number* (`view-num`) is a monotonically increasing number
which changes every time there is a change of primary replica in
the ensemble.

Each replica must also know who the current primary replica is.
This is stored in the `primary` field.

The `status` field shows the current replica operation mode.
As we will see later, the `status` can assume different values
depending whether the replica is ready to process client requests,
or it is getting ready and doing internal preparation.

Every replica node will also have a list of all the replica
nodes in the ensemble with their IP addresses and their
unique identifiers. Some parts of the protocol require
the replicas to communicate with other replicas therefore
they must know how to contact the other nodes.

The `client-table` is used to keep track of client's requests.
Clients are identified by a unique id, and each client can only
make one request at the time. Since communication is considered
unreliable, clients can re-issue the same request without the
risk of duplication in the system. Every client request
has a monotonically increasing number which identify the request
of a particular client. Each time the primary receives a client
requests it add the request to the client table. If the client
re-sends the same requests because didn't receive the response
the primary can verify that the request was already processed and
send the cached response.

*For brevity, the pictures which will follow will omit some details*.

## The Protocol

Next we are going to analyse the protocol in details.

(tell about simplicity and efficiency trade off with
optmisations).

### Client requests handling.


---

Links and resources:

   [^1]: [The Byzantine Generals Problem, Lamport](https://www.microsoft.com/en-us/research/publication/byzantine-generals-problem/)
