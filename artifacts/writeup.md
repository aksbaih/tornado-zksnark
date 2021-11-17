Name: Akram Sbaih & Eric Zhou

## Question 1

In the following code-snippet from `Num2Bits`, it looks like `sum_of_bits`
might be a sum of products of signals, making the subsequent constraint not
rank-1. Explain why `sum_of_bits` is actually a _linear combination_ of
signals.

```
        sum_of_bits += (2 ** i) * bits[i];
```

## Answer 1
It is not the product of signals because `(2 ** i)` is not a signal even though `bits[i]` is defined as a signal. 
Instead, `(2 ** i)` is a constant since `i` is looping over a known `n` at compile-time.
The sum of products of constants and signals is a linear combination of those signals, as desired.


## Question 2

Explain, in your own words, the meaning of the `<==` operator.

## Answer 2
It combines the assignment `<--` and the constraint `===` operations.
For example, constraint-assigning a number to the input signal of `Num2Bits` both converts that number into an array of
bits *AND* asserts the constraints of that circuit, such as the fact that this number is fully-expressible by the given
number of bits `b`.


## Question 3

Suppose you're reading a `circom` program and you see the following:

```
    signal input a;
    signal input b;
    signal input c;
    (a & 1) * b === c;
```

Explain why this is invalid.

## Answer 3
Constraints are only valid for `R1C`'s (i.e. quadratic expressions). The bitwise-and operator on the left-hand side of 
the last line is not a quadratic expression. 

