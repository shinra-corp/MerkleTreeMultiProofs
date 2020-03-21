# MerkleTreeMultiProofs

Library that implement a selected multi proof system with Merkle Tree.

Objective

Deploy on chain a tool that helps smart contract developers to incorporate a merkle tree functionality with the possibility of selecting a subset of proofs in opposition of giving all the proofs. 

The library calculates the root of the tree based on the information given.
That information is split in two arrays that we will define below.

The general idea is to have a Merkle Tree capable of generating the correct root given a subset of leafs and all the intermediary nodes values.

The user should review there's proof requirements before using this tool.
The ideal case is when we have 2^n leafs. If there is less of that number, the user can fill the leafs with dumb data, and make the approprieted changes. 

Important
Understanding the reconstructing algorithm will allow the user to make better choices on the tree itself, giving the system a tree which is more efficient to calculate.


General idea of the reconstruction is split in three steps.

The user call the function giving a input array that follow a predefined rule:

First elements of the array are the leaves that the user wants to proof, after the last leaf element of the array is a BLANK SYMBOL, and the rest of the array is an intermediary node hashes.

The BLANK SYMBOL is only the # = Keccak(0). This value is considered a reserved work.

Conceptually we can think as something in the line of: 

[ A ; B ; C ; D ; E ; F ; # ; i1 ; i2 ; i3 ; i4; …]

The user should also give a generalized index order operation array, GIOT for friends.
The GIOT is nothing more than the indexes in the generalized form for each element in the input array.

We don't need all the GIOT information about the leaves, we know that for each leaf there is always a sibling. So we don't include the sibling index.

Conceptually we can think as something in the line of: 
[10 ; 12 ; 4 ; 5]


Note that the order is in relation to the level (heights) of the tree. We don’t need to include the BLANK SYMBOL where because we can infer the level change by comparing i < i -1



Steps: 

The first step of the process is hashing all the pairs of leafs in the first part of the array.
We can locale the parent generalized index position by : p = FLOOR( i-1 / 2)

We save this information to use later in the next level.

Second step we calculate all the intermediate nodes with the given information and the result of step one. We continue this step until we go through all the GIOT elements.


In the third step we find the branch we don't have calculated, we know that is or in index 1 or 2. Lastly we return the root to the caller.





Formulas and observations:

Find the parent generalized index : p = FLOOR( i-1 / 2)
Find left / right child : LEFT : 2k +1 ; RIGHT : 2k + 2 

The depth of the tree is the number of steps from root to leaf.

The tree must have this requirements:

Must be a FULL COMPLETE BINARY TREE (leaves are 2, 4, 8, 16, 32, etc...)


Note: From a parent node the left child is always a odd index number and the right is always an even number.


