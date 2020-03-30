# Specification of the Generalized Index Merkle Tree Library

The tree is define as Full Complete Binary Tree.
There is a one-way function that is easy to compute, but difficult to invert. h

For each node, there is a unique positive integer called generalized index, gi, given top to bottom, left to right so that parent generalized index, p = FLOOR(gi - 1 / 2), left child lc = 2gi + 1, right child rc = 2gi + 2 is computable to all cases.


Each node is composed of the hash of the two imediate children such that h(h(child1), h(child2)).
Each leaf is composed of the hash of some proof such that h(proof).
Each leaf as a sibling leaf such that h(leaf, sibling) is computable.

