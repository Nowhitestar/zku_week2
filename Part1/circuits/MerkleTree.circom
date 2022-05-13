pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var hash[n+1][2**n];
    // compute the first layer hash
    for (var i=0; i<(2**n); i++) {
        hash[0][i] = leaves[i];
    }
    component poseidon2[2**n][2**n];
    // compute hash of the remain layers
    for (var i=1; i<(n+1); i++) { // n layers
        for (var j=0; j<2**(n-i); j++) {
            poseidon2[i][j] = Poseidon(2);
            poseidon2[i][j].inputs[0] <== hash[i-1][2*j];
            poseidon2[i][j].inputs[1] <== hash[i-1][2*j+1];
            hash[i][j] <== poseidon2[i][j].out;
        }
        
    }
    root <== hash[n][0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon2[n];
    for (var i=0; i<n; i++) {
        poseidon2[i] = Poseidon(2);
        if (i==0) {
            poseidon2[i].inputs[0] <== leaf;
            poseidon2[i].inputs[1] <== path_elements[i];
        } else {
            poseidon2[i].inputs[0] <== poseidon2[i-1].out + (path_elements[i]-poseidon2[i-1].out)*path_index[i];
            poseidon2[i].inputs[1] <== path_elements[i] - (path_elements[i]-poseidon2[i-1].out)*path_index[i];
        }
    }
    root <== poseidon2[n-1].out;
}