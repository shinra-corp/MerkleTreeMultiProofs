pragma solidity ^0.6.0 <0.7.0;

import "./MerkleTreeGenIndex.sol";

/*
    In this example we are spliting the processing of one tree in many branches. Each leaf is a tree by itself
    Important point: We can imagine a very large tree of trees, but in the end is the same as a unique tree.

    This code is just to give an idea.
*/

contract ExampleForest {

    bytes32 public root;

    bytes32[] public subtrees;

    MerkleTreeGenIndex.Data ram;

    constructor(bytes32 _root) public {
        root = _root;
    }

    //Call this function for each subtree you want to validate
    function calculateRootOfSubTree(bytes32[] memory _nodes, uint256[] memory _GIOP) public {
        subtrees[subtrees.length - 1] = callLibraryToCalculateRoot(_nodes, _GIOP);
    }

    //Here we are assuming that the Principal tree is bigger than the subtrees saved in this contract, and the user give the complete GIOP array
    function calculateRootOfPrincipalTree(bytes32[] memory _nodes, uint256[] memory _GIOP) public returns(bool) {
        bytes32[] memory _orderNodes;

        for(uint256 i = 0; i < subtrees.length; i = i + 2) {
            //each leaf as a sibling
            _orderNodes[i] = subtrees[i];
            _orderNodes[i+1] = subtrees[i+1];
        }

        //lets add a BLANK POINT
        _orderNodes[_orderNodes.length] = keccak256(abi.encodePacked(uint256(0)));

        //let skip the leaves GIOP
        uint256 _skip = (subtrees.length / 2) + 1; // +1 because of BLANK_POINT
        uint256 j;

        //lets add to the array the nodes info
        for(uint256 i = _skip; i < _GIOP.length; i++) {
            _orderNodes[i] = _nodes[j];
            j += 1;
        }


        return root == callLibraryToCalculateRoot(_orderNodes, _GIOP);
    }

    //Note that we make a call with the library always the same way
    function callLibraryToCalculateRoot(bytes32[] memory _nodes, uint256[] memory _GIOP) internal returns(bytes32){
        return MerkleTreeGenIndex.getRoot(ram, _nodes, _GIOP);
    }
}
