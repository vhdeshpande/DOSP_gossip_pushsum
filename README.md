# Project 2: Gossip and Push Sum Algorithm
This project aims to analyze gossip-type algorithms using an Erlang actor model simulator to determine their convergence using various topologies. The topology defines how nodes are connected. Because the actors are operating asynchronously, this is also known as asynchronous gossip.
### Authors:
* Vaibhavi Deshpande
* Ishan Kunkolikar
### Pre-requisites:
* Erlang/OTP version - 25.1
### Steps to run:
Commands to start the algorithm:
``` 
c(gossipAndPushSum).
gossipAndPushSum:start_gossip ( number_of_nodes, topology, algorithm ).
```
Where ‘number_of_node’ is the number of nodes in the topology, ‘topology’ is the topology which includes full network, line, 2D grid, and Imperfect 3D and the algorithm includes gossip or push sum algorithm

### Implementation details:
* **Gossip Algorithm**: The gossip algorithm spreads the message across the network. Every node in the topology randomly selects and transmits the message to the node to which it is connected in the network. After receiving the rumour ten times, the nodes stop transmitting the message.
The Gossip algorithm for information propagation involves the following:
    * **Starting**: A participant(actor) it told/sent a rumor(fact) by the main process.
    * **Step**: Each actor selects a random neighbor and tells it the rumor.
    * **Termination**: Each actor keeps track of rumors and how many times it has heard the rumor. It stops transmitting once it has heard the rumor 10 times (10 is arbitrary, other values can be selected).

* **Push Sum Algorithm**: In the push sum algorithm, each node maintains two values- s and w. Upon receiving a message, it adds the received weights to its s and w and while transmitting the message the node sends half of its weights. Each node will terminate when its ratio of s/w does not change more than 10-10 for up to three iterations. Push-Sum algorithm for sum computation
  * **State**: Each actor Ai maintains two quantities: s and w. Initially, s = xi = i (that is actor number i has value i, play with other distribution if
you so desire) and w = 1.
  * **Starting**: Ask one of the actors to start from the main process.
  * **Receive**: Messages sent and received are pairs of the form (s, w). Upon receive, an actor should add received pair to its own corresponding values. Upon receive, each actor selects a random neighboor and sends it a message.
  * **Send**: When sending a message to another actor, half of s and w is kept by the sending actor and half is placed in the message.
  * **Sum estimate**: At any given moment of time, the sum estimate is s/w where s and w are the current values of an actor.
  * **Termination**: If an actors ratio s/w did not change more than 10<sup>-10</sup> in 3 consecutive rounds the actor terminates. WARNING: the values s
and w independently never converge, only the ratio does.

### Topologies:
The actual network topology plays a critical role in the dissemination speed of Gossip protocols. The topology determines who is considered a neighboor in the above algorithms.
* **Full Network**: Every actor is a neighbor of all other actors. That is, every actor can talk directly to any other actor.
* **2D Grid**: Actors form a 2D grid. The actors can only talk to the grid neighbors.
* **Line**: Actors are arranged in a line. Each actor has only 2 neighbors (one left and one right, unless you are the first or last actor).
* **Imperfect 2D Grid**: Grid arrangement but one random other neighbor is selected from the list of all actors (4+1 neighbors).

### Largest Number of Nodes for Gossip Algorithm:
1. Full – 1000
2. Line – 500
3. 2D Grid -700
4. Imperfect 3D – 700
### Largest Number of Nodes for Push Sum Algorithm –
1. Full – 500
2. Line – 100
3. 2D Grid -500
4. Imperfect 3D - 500
