pragma solidity ^0.6.0 <0.7.0;

library MerkleTreeGenIndex {

    bytes32 constant BLANK_POINT = keccak256(abi.encodePacked(uint256(0)));

    struct Data {
        mapping(uint256 => bytes32) ram;
    }

    function getRoot(
        Data storage self,
        bytes32[] memory nodes,
        uint256[] memory giop
    )
    public
    returns(bytes32)
    {
        //We need three phases to process the root
        //This pointer to Generalized Index Array
        uint256 giop_pointer;
        uint256 index;
        uint256 parentId;

        //Lets generate the node for each pair given, until find blank point
        //Loop leafs until find BLANK_POINT or complete the array
        while(index < nodes.length) {
            if(nodes[index] != BLANK_POINT) {
                self.ram[(giop[giop_pointer] - 1) / 2] = keccak256(abi.encodePacked(nodes[index], nodes[index+1]));
                giop_pointer += 1;
                index += 1;
            } else {
                index += 1;
                break;
            }
        }

        //Main work for generating all the intermedian nodes
        while(index < giop.length) {
            parentId = (giop[giop_pointer] - 1) / 2;

            if(giop[giop_pointer] % 2 == 0) {
                self.ram[giop[parentId]] = keccak256(
                    abi.encodePacked(self.ram[giop[giop_pointer] - 1], nodes[index])
                );
            } else {
                self.ram[giop[parentId]] = keccak256(
                    abi.encodePacked(nodes[index], self.ram[giop[giop_pointer] + 1])
                );
            }
            index += 1;
            // if we are at the end of the array break, there is no more work do to at this stage
            if(giop_pointer == giop.length - 1) {
                break;
            }
            giop_pointer += 1;
        }

        //Calculate root with data
        //if last parent is even then we are at the right side of the tree
        if(parentId % 2 == 0) {
            parentId = parentId - 1;
        } else {
            parentId = parentId + 1;
        }

        // left node 2k+1 - right node 2k+2
        self.ram[parentId] = keccak256(
                abi.encodePacked(self.ram[2 * parentId + 1], self.ram[2 * parentId + 2])
            );

        return keccak256(abi.encodePacked(self.ram[1], self.ram[2]));
    }
}
