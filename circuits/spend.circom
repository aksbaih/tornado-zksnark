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
    out <== (condition) * true_value + (1 - condition) * false_value;
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
    component ifthenelse[] = [IfThenElse(), IfThenElse()];
    
    // now use the components to switch conditionally
    // first output 
    ifthenelse[0].condition <== s;
    ifthenelse[0].true_value <== in1;
    ifthenelse[0].false_value <== in0;
    out0 <== ifthenelse[0].out;
    
    // second output
    ifthenelse[1].condition <== s;
    ifthenelse[1].true_value <== in0;
    ifthenelse[1].false_value <== in1;
    out1 <== ifthenelse[1].out;
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
}
