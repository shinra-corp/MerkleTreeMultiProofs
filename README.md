# MerkleTreeMultiProofs
 
Library that implements a selected multi proof system with Merkle Tree.
 
## Objective
 
Deploy on chain a tool that helps smart contract developers to incorporate a merkle tree functionality with the possibility of selecting a subset of proofs in opposition of giving all the proofs.
 
The library calculates the root of the tree based on the information given.
That information is split in two arrays that we will define below.
 
The general idea is to have a Merkle Tree capable of generating the correct root given a subset of leafs and all the necessary intermediary nodes values.
 
The user should review there's proof requirements before using this tool.

The ideal case is when we have 2^n leafs. If there is less of that number, the user can fill the leafs with dumb data, and make the approprieted changes.
 
## Important

Understanding the reconstructing algorithm will allow the user to make better choices on the tree itself, feeding the system with a tree which is more efficient to calculate.

You should sort your leaves so that when you are validation with this library you have less computation requirements and save some GAS.
 
## Context
 
Merkle tree is a data structure that calculates each node value by hashing the values of two subnodes. If you don't know much about Merkle Tree please refer to : [article](https://medium.com/hackernoon/merkle-trees-181cb4bc30b4) and [wikipidia](https://en.wikipedia.org/wiki/Merkle_tree) to get an basic idea.
 
The main point of using a Merkle Tree is data integrity checks. You can recalculate the tree from the leaves (most bottom nodes) until the root (most upper node) and check if the data was temper in the same way.
 
We have the same libraries in solidity that implement this basic use case, but they have a problem of scale. The biggest problem is that to validate a tree root you have to submit all the leaves.

If you have to submit all the leaves to calculate the root, you are bound to that limit. If you have a tree with 32 leaves, than you have to commit all the 32 leaves.

By using a coordenation system as the Generalized Index, we can selective choose each leaf to be part of the computation. This is the natural usage of a Merkle Tree.

By having this capacity of selection we can construct one tree that can represent many proof system.
 
Merkle Tree by itself is a multi part proof system, here you can select some leafs to "prove" and give the intermediate node values as needed. We will see with more detail below that this means.
 
This library aims to implement that functionality in a way that is useful to a large use case and at the same time don't be very opinionated about the proof that you are trying to make.


## Generalized Index

Coordenation system that can help when we need to specify one node or leaf.

Start from the top of the tree and set the root as zero (0), then top / botton increment that index value by 1 until all nodes and leaves are enumerated

    
```mermaid
graph TD
 
 root --> | 1 | a/b
 root --> | 2 | c/d
 
 a/b --> | 3 | a
 a/b --> | 4 | b
 c/d --> | 5 | c
 c/d --> | 6 | d
 
 ```
 
 
## To clarify the terminology used in this document:
 
* Proof is something you submit as a secret to the system, normally in the form of a hash value.

* Reveal is something you submit so the system can check (hash it and compare) against the Proof.

* These two sets are commonly known as a commit / reveal scheme. First you commit to something, then you reveal that something.

* A leaf is a node that doesn't have children. Is the bottom of the tree.

* A root is the upper node, Is the top of the tree.

* A binary tree is when each node has only two childs, not counting the last ones (leaves).

* A complete binary tree is when each node have two children, minus the leaves. All nodes are organized top / bottom, and left to right.

* A full binary tree is when you have a tree that is complete and the leaves are also completed. You don't have missing leaves.
 
 
## A Full Complete Binary Tree with the generalized index from root to leafs.
 
```mermaid
graph TD
 
 root --> | 1 | abcd/efgh
 root --> | 2 | ijkl/mnop
 abcd/efgh --> | 3 | ab/cd
 abcd/efgh --> | 4 | ef/gh
 ijkl/mnop --> | 5 | ij/kl
 ijkl/mnop --> | 6 | mn/op
 
 ab/cd --> | 7 | a/b
 ab/cd --> | 8 | c/d
 ef/gh --> | 9 | e/f
 ef/gh --> | 10 | g/h
 ij/kl --> | 11 | i/j
 ij/kl --> | 12 | k/l
 mn/op --> | 13 | m/n
 mn/op --> | 14 | o/p
 
 a/b --> | 15 | a
 a/b --> | 16 | b
 c/d --> | 17 | c
 c/d --> | 18 | d
 e/f --> | 19 | e
 e/f --> | 20 | f
 g/h --> | 21 | g
 g/h --> | 22 | h
 i/j --> | 23 | i
 i/j --> | 24 | j
 k/l --> | 25 | k
 k/l --> | 26 | l
 m/n --> | 27 | m
 m/n --> | 28 | n
 o/p --> | 29 | o
 o/p --> | 30 | p
 
 ```
 
 
In this example if we need to calculate the root node we have to submit 16 leaves (a to p).
 
You can see that this is not very efficient. The Merkle Tree classic usage is to split the proofs (leaves) and the intermediate value (nodes) in such a way is less expensive than submitting all the leaves.
 
This library implements such functionality.
 
Let's see one example to make thing more clear:
 
 
```mermaid
 
graph TD
 root:::calculation --> | 1 | abcd/efgh:::calculation
 root --> | 2 | ijkl/mnop:::calculation
 abcd/efgh --> | 3 | ab/cd:::calculation
 abcd/efgh --> | 4 | ef/gh:::intermedian
 ijkl/mnop --> | 5 | ij/kl:::intermedian
 ijkl/mnop --> | 6 | mn/op:::calculation
 
 ab/cd --> | 7 | a/b:::calculation
 ab/cd --> | 8 | c/d:::intermedian
 ef/gh --> | 9 | e/f
 ef/gh --> | 10 | g/h
 ij/kl --> | 11 | i/j
 ij/kl --> | 12 | k/l
 mn/op --> | 13 | m/n:::calculation
 mn/op --> | 14 | o/p:::intermedian
 
 a/b --> | 15 | a:::proof
 a/b --> | 16 | b:::proof
 c/d --> | 17 | c
 c/d --> | 18 | d
 e/f --> | 19 | e
 e/f --> | 20 | f
 g/h --> | 21 | g
 g/h --> | 22 | h
 i/j --> | 23 | i
 i/j --> | 24 | j
 k/l --> | 25 | k
 k/l --> | 26 | l
 m/n --> | 27 | m:::proof
 m/n --> | 28 | n:::proof
 o/p --> | 29 | o
 o/p --> | 30 | p
 
 classDef proof fill:#f9f,stroke:#333,stroke-width:1px;
 classDef intermedian fill:#8fc,stroke:#333,stroke-width:1px;
 classDef calculation fill:#ed5,stroke:#333,stroke-width:1px;
 
 ```
 
The pink color (#f9f) is the leaves that we want to prove something
 
The green color (#8fc) are the intermediate nodes we need to also give to the function
 
The yellow color (#ed5) are the nodes that the function calculate based on the data given
 
As you can see, instead of passing the 16 leaves we are passing 4 leaves + 4 intermediate nodes, 8 in total.
 
 
 
## Why are generalized indexes important?
 
They are important because they let the code localized each individual nodes. You can think as a coordination system for Trees.
 
 
## So I only need to send the data of the leaves and nodes and I'm done?
 
No, you have also to provide the Generalized Index of each point of data you are giving to the function. We call that information GIOP, Generalized Index - Order Operation. This information serve two purposes:
 
Let the function localize each node.
Let the function know where to stop.
 
The GIOP of each node is important but also the order that you construct the array.
 
 
 
 
## General idea of the reconstruction can be splited in three steps.
 
The user call the function giving a input array that follow a predefined rule:
 
First elements of the array are the leaves that the user wants to proof, after the last leaf element of the array is a BLANK SYMBOL, and the rest of the array is an intermediary node hashes.
 
The BLANK SYMBOL is only the # = Keccak(0). This value is considered a reserved work.
 
Conceptually we can think as something in the line of:

 
[ A ; B ; C ; D ; E ; F ; # ; i1 ; i2 ; i3 ; i4; …]

Where

A to F are leaves

\# is the BLANK POINT

i1 to in are the intermedian nodes

 
The user should also give a generalized index order operation array, GIOP for friends.
The GIOP is nothing more than the indexes in the generalized form for each element in the input array.
 
### We don't need all the GIOP information about the leaves, we know that for each leaf there is always a sibling. So we don't include the sibling index.
 
Conceptually we can think as something in the line of:
[10 ; 12 ; 4 ; 5]
 
 
Note that the order is in relation to the level (heights) of the tree. We don’t need to include the BLANK SYMBOL where because we can infer the level change by comparing i < i -1
 
 
 
## Steps:

### First: Process all leaves by hashing each pair

The first step of the process is hashing all the pairs of leafs in the first part of the array.
We can locale the parent generalized index position by : p = FLOOR( i-1 / 2)
 
We save this information to use later in the next level.

### Second: Calculate intermediate nodes
 
Second step we calculate all the intermediate nodes with the given information and the result of step one. We continue this step until we go through all the GIOP elements.
 
### Third: Calculate the last branch and return root to caller
 
In the third step we find the branch we don't have calculated, we know that is or in index 1 or 2. Lastly we return the root to the caller.
 
  
 
 
## Formulas and observations:

### Using the Generalized index
 
Find the parent with generalized index : p = FLOOR( i-1 / 2)

Find left / right child : LEFT : 2k + 1 ; RIGHT : 2k + 2
 
The depth of the tree is the number of steps from root to leaf.
 
## The tree must have this requirements:
 
Must be a FULL COMPLETE BINARY TREE (leaves are 2, 4, 8, 16, 32, etc...)
 
Note: From a parent node the left child is always an odd index number and the right is always an even number.



## From client Perspective (Example)

### Let go with the graph show before

```mermaid
 
graph TD
 root:::calculation --> | 1 | abcd/efgh:::calculation
 root --> | 2 | ijkl/mnop:::calculation
 abcd/efgh --> | 3 | ab/cd:::calculation
 abcd/efgh --> | 4 | ef/gh:::intermedian
 ijkl/mnop --> | 5 | ij/kl:::intermedian
 ijkl/mnop --> | 6 | mn/op:::calculation
 
 ab/cd --> | 7 | a/b:::calculation
 ab/cd --> | 8 | c/d:::intermedian
 ef/gh --> | 9 | e/f
 ef/gh --> | 10 | g/h
 ij/kl --> | 11 | i/j
 ij/kl --> | 12 | k/l
 mn/op --> | 13 | m/n:::calculation
 mn/op --> | 14 | o/p:::intermedian
 
 a/b --> | 15 | a:::proof
 a/b --> | 16 | b:::proof
 c/d --> | 17 | c
 c/d --> | 18 | d
 e/f --> | 19 | e
 e/f --> | 20 | f
 g/h --> | 21 | g
 g/h --> | 22 | h
 i/j --> | 23 | i
 i/j --> | 24 | j
 k/l --> | 25 | k
 k/l --> | 26 | l
 m/n --> | 27 | m:::proof
 m/n --> | 28 | n:::proof
 o/p --> | 29 | o
 o/p --> | 30 | p
 
 classDef proof fill:#f9f,stroke:#333,stroke-width:1px;
 classDef intermedian fill:#8fc,stroke:#333,stroke-width:1px;
 classDef calculation fill:#ed5,stroke:#333,stroke-width:1px;
 
 ```

 The node array should be like:

 [a, b, m, n, #, c/d, o/p, ef/gh, ij/kl]

The GIOP array should be like

[15, 27, 8, 14, 4, 5]

References:

* [generalized-merkle-tree-index](https://github.com/ethereum/eth2.0-specs/blob/dev/ssz/merkle-proofs.md#generalized-merkle-tree-index)
* [ERC2429](https://gitlab.com/status-im/docs/EIPs/blob/secret-multisig-recovery/EIPS/eip-2429.md)

