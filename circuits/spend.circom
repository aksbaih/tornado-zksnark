include "./mimc.circom";

/*
 * IfThenElse sets `out` to `true_value` if `condition` is 1 and `out` to
 * `false_value` if `condition` is 0.
 *
 * It enforces that `condition` is 0 or 1.
 *
 */
template IfThenElse() {
    signal input condition;
    signal input true_value;
    signal input false_value;
    signal output out;

    // TODO
    // Hint: You will need a helper signal...
    
    // first, verify that the condition is indeed 0 or 1
    (condition) * (1 - condition) === 0;

    // assign the output to be a linear combination of the two quadratic forms
    signal true_side;
    signal false_side;
    true_side <== (condition) * true_value;
    false_side <== (1 - condition) * false_value;
    out <== true_side + false_side;
}

/*
 * SelectiveSwitch takes two data inputs (`in0`, `in1`) and produces two ouputs.
 * If the "select" (`s`) input is 1, then it inverts the order of the inputs
 * in the ouput. If `s` is 0, then it preserves the order.
 *
 * It enforces that `s` is 0 or 1.
 */
template SelectiveSwitch() {
    signal input in0;
    signal input in1;
    signal input s;
    signal output out0;
    signal output out1;

    // TODO
    // first, define ifthenelse as a componenet
    component ifthenelse0 = IfThenElse();
    component ifthenelse1 = IfThenElse();
    
    // now use the components to switch conditionally
    // first output 
    ifthenelse0.condition <== s;
    ifthenelse0.true_value <== in1;
    ifthenelse0.false_value <== in0;
    out0 <== ifthenelse0.out;
    
    // second output
    ifthenelse1.condition <== s;
    ifthenelse1.true_value <== in0;
    ifthenelse1.false_value <== in1;
    out1 <== ifthenelse1.out;
}

/* This helper function runs the Merkle tree hash process for a given leaf_hash
 * and list of siblings and directions. The out signal will store the resulting 
 * Merkle root given the input signals.
 */
template MerkleProcess(depth) {
    signal input leaf_hash;
    signal input sibling[depth];
    signal input direction[depth];
    signal output out;

    // define a list of hash circuit for each layer of the Merkle tree
    component selective_switch[depth];
    component H[depth];
    signal hashes[depth + 1];
    hashes[0] <== leaf_hash;

    // iterate over the depth of the Merkle tree to assert the provided proof
    for(var i = 0; i < depth; ++i) {
        // create the necessary switch and hash circuits for this layer
        selective_switch[i] = SelectiveSwitch();
        H[i] = Mimc2();
        // setup the switch circuit which depends on direction[i]
        selective_switch[i].s <== direction[i];
        selective_switch[i].in0 <== hashes[i];
        selective_switch[i].in1 <== sibling[i];
	// setup the hash function in the order produced by the switch circuit
        H[i].in0 <== selective_switch[i].out0;
        H[i].in1 <== selective_switch[i].out1;
        // store the hash value in the list of hashes
        hashes[i + 1] <== H[i].out;
    }

    // store the final hash as the result of the merkle process
    out <== hashes[depth];
}

/*
 * Verifies the presence of H(`nullifier`, `nonce`) in the tree of depth
 * `depth`, summarized by `digest`.
 * This presence is witnessed by a Merle proof provided as
 * the additional inputs `sibling` and `direction`, 
 * which have the following meaning:
 *   sibling[i]: the sibling of the node on the path to this coin
 *               at the i'th level from the bottom.
 *   direction[i]: "0" or "1" indicating whether that sibling is on the left.
 *       The "sibling" hashes correspond directly to the siblings in the
 *       SparseMerkleTree path.
 *       The "direction" keys the boolean directions from the SparseMerkleTree
 *       path, casted to string-represented integers ("0" or "1").
 */
template Spend(depth) {
    signal input digest;
    signal input nullifier;
    signal private input nonce;
    signal private input sibling[depth];
    signal private input direction[depth];

    // TODO
    // define a hash ciruit used to hash the leaf
    component H = Mimc2();
    H.in0 <== nullifier;
    H.in1 <== nonce;
    // define a MerkleProcess ciruit used to evaluate the provided proof
    component merkle_process = MerkleProcess(depth);
    merkle_process.leaf_hash <== H.out;
    for(var i = 0; i < depth; ++i) {
        merkle_process.sibling[i] <== sibling[i];
        merkle_process.direction[i] <== direction[i];
    }
    // assert that the resulting Merkle root matches the digest
    merkle_process.out === digest;
}

