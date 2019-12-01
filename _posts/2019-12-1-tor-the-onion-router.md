---
layout: post
title: "Dive into Tor (The Onion Router)"
author: "Gaoping Huang"
tags: Tor
use_math: false
use_bootstrap: false
---
The Onion Router, commonly referred as "Tor", is a well-known technique for anonymous communication. In an onion network, messages are first encrypted, and go through a series of randomly picked proxies (called *onion routers*) before reaching the destination. Therefore, it is very difficult (although not impossible) to trace the message sender.

I am very interested in its underlying theory and implementation, but cannot find a post that covers enough details of what I want to know about it. So here I summarize my findings from some publications and blog posts.

### Basic theory of Tor

The core idea of Tor is a data structure called *onion*. When a user wants to send a message to a destination, the Tor client first randomly selects a set of nodes (*onion routers*) to transmit the message, then use their shared keys to encrypt the original message into as many layers as there are nodes. This is analogous to layers of an onion. For example, suppose the chosen nodes are A, B, and C in which the message will go though A→B→C and finally reach the destination. The original message of the sender will be first encrypted by the shared key of node C, then further encrypted by the key of B, and finally by the key of A. The diagram is shown below:
![onion diagram](/assets/imgs/onion-diagram.svg)
    (Figure 1. An onion with three layers. Image credit: Wikipedia user [HANtwister](https://en.wikipedia.org/wiki/Onion_routing#/media/File:Onion_diagram.svg))

Once the onion is created, it will be transmitted along the path of A→B→C. Each node in this path will "peel" off one layer of the onion by decrypting with its own private key. For example, when the onion arrives at node A, the outer layer is "peeled" off by the private key of A. Then node A sends the onion to the next node B, and then C. After decrypting by node C, the message is in plaintext, which will be sent to the actual destination. When a message is sent back from the destination to the sender, the reverse order of encryption is used.

In this process, each node only knows the identity (e.g., IP address) of its previous one and next one, but has no idea of other routers in the path. They also cannot recognize 1) whether the previous node is the sender or just an intermediary node; 2) whether the next node is the receiver or just another intermediary node. This protects the anonymity. Furthermore, since the messages are encrypted with keys of other nodes, each node cannot acquire the original messages, which prevents eavesdropping. The only exception is the "exit" node, which is the final node and responsible for sending the plaintext messages to the receiver. This weakness will be discussed later.

### Implementation details
To achieve the above transmission, several implementation details need to be considered:

1. When a user connects to Tor network, the Tor client needs to randomly select a set of nodes. This is provided by public ["directory servers"](https://metrics.torproject.org/rs.html#search/flag:authority) which maintain the node information that is publicly listed. Each node/router/relay is run by volunteers. Anyone can configure a server to be one of the thousands of routers used by millions of Tor users. According to the [Tor Metrics](https://metrics.torproject.org/) (as of Nov 2019), there are about 6000 relays serving 1.8 million users.
2. The number of chosen nodes is typically three, which is a trade-off between anonymity and network speed. Three nodes are called "entry", "middle", and "exit", respectively. For every 10 minutes or so, the Tor client will choose another three nodes among thousands of nodes. During the 10-minute window, each node maintains a long-time socket connection with the next node.
3. Once the three nodes are chosen, the sender needs to get their keys to encrypt the message (i.e., create an onion). There are two options. The first option is to negotiate the keys separately with three nodes using Diffie–Hellman key exchange. For each node, the shared key is only known by itself and the sender, while the other two do not know. The second option is to fetch the public key from the public directory servers, based on RSA algorithm.
4. The sender encrypts the message using the key of the "exit" node, then the key of "middle" node, and finally the "entry" node. Then the onion is sent to the entry → middle → exit node for "peeling".
5. Tor network is running on the application layer, not IP layer. 


### Weakness
As mentioned early, there is a security threat with the exit nodes. If an exit node is compromised, the attacker can capture the sensitive information from the message. This can be resolved by using an HTTPS connection. Hence the message can be seen by the exit node is still encrypted. According to [3], a nice and interactive illustration of how Tor works with and without HTTPS can be found [here](https://www.eff.org/pages/tor-and-https) by Electronics Frontier Foundation.

Another weakness is that the Internet service providers (ISP) can trace and log connections between computers. By comparing the timestamp and exact size of the message, there is a chance to identify the sender. But keep in mind, the routers are running around the world, which raises the cost and difficulty of tracing the connections with ISP from different countries. Also, ["garlic routing"](https://en.wikipedia.org/wiki/Garlic_routing) is proposed as a variant of onion routing to encrypt multiple messages together, which both increases the speed of data transfer and makes it more difficult to perform traffic analysis.


### References

1. [Onion routing - Wikipedia](https://en.wikipedia.org/wiki/Onion_routing) 
2. Shavers, B., Bair, J., 2016. [Chapter 2 - The Tor Browser](https://doi.org/10.1016/B978-0-12-803340-1.00002-1), in: Shavers, B., Bair, J. (Eds.), Hiding Behind the Keyboard. Syngress, Boston, pp. 11–34.
3. [Deep Dive Into TOR (The Onion Router)](https://blog.insiderattack.net/deep-dive-into-tor-the-onion-router-6de4c25beba7) by Deepal Jayasekara.
4. Reed, M.G., Syverson, P.F. and Goldschlag, D.M., 1998. Anonymous connections and onion routing. IEEE Journal on Selected areas in Communications, 16(4), pp.482-494.