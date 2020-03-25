pragma solidity ^0.6.0 <0.7.0;

/*
    This Library is the extended version, with many comments.
*/

library MerkleTreeGenIndex {

    // Define the reserved word as BLANK_POINT to be the hash of 0
    bytes32 constant BLANK_POINT = keccak256(abi.encodePacked(uint256(0)));

    // The caller should have this struct so we can save information to compute later
    struct Data {
        mapping(uint256 => bytes32) ram;
    }



    // The only function of this library. The caller should organize the data as define in the EIP XXXX and call this method.
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


        //Note that we are not using a for loop, because of clarity and also we need the index to be the same in next loop.

        /*
                STEP 1
        */
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


        /*
            STEP 2
        */
        //Main work for generating all the intermedian nodes
        while(index < giop.length) {
            //get the GIOP give by user, and calculate the parent ID of that node
            parentId = (giop[giop_pointer] - 1) / 2;

            // The order of hashing is important so we can calculate the same root
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

        /*
            STEP 3
        */
        //Calculate root with data
        //if last parent is even then we are at the right side of the tree, we check this so we can hash in the correct order
        if(parentId % 2 == 0) {
            parentId = parentId - 1;
        } else {
            parentId = parentId + 1;
        }

        // left node 2k+1 - right node 2k+2
        self.ram[parentId] = keccak256(
                abi.encodePacked(self.ram[2 * parentId + 1], self.ram[2 * parentId + 2])
            );

        //calculate the root and return to caller
        return keccak256(abi.encodePacked(self.ram[1], self.ram[2]));
    }
}
