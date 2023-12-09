from pathlib.path import Path
from math import pow

fn get_next_seq(seq: DynamicVector[Int]) -> DynamicVector[Int]:
    var next_seq = DynamicVector[Int]()
    for i in range(len(seq) - 1):
        next_seq.push_back(seq[i+1] - seq[i])

    return next_seq

fn get_next_value(seq_in: DynamicVector[Int]) -> Int:
    var last_vals = SIMD[DType.int64, 32]()
    var seq = seq_in
    last_vals[0] = seq[len(seq)-1]
    for i in range(len(seq)-1):
        seq = get_next_seq(seq)
        last_vals[i+1] = seq[len(seq)-1]
        var prt: String = ''
        for i in range(len(seq)):
            prt += str(seq[i]) + ' '
    
    return int(last_vals.reduce_add())

fn mainQ1() raises:
    let inpt = Path('./day9/input.txt').read_text().split('\n')

    var q1_sum = 0
    for i in range(len(inpt)):
        let seq_str = inpt[i].split(' ')
        var seq = DynamicVector[Int]()
        for i in range(len(seq_str)):
            # print(seq_str[i])
            seq.push_back(atol(seq_str[i]))

        q1_sum += get_next_value(seq)
    
    print(q1_sum)

fn get_first_value(seq_in: DynamicVector[Int]) -> Int:
    var first_vals = SIMD[DType.int64, 32]()
    var seq = seq_in
    first_vals[0] = seq[0]
    for i in range(len(seq)-1):
        seq = get_next_seq(seq)
        # we only actually need the first line of values (the diagonal)
        # to extrapolate - keep those to sum
        first_vals[i+1] = seq[0]
        var prt: String = ''
        for i in range(len(seq)):
            prt += str(seq[i]) + ' '
    
    var q2_sum = 0
    for i in range(len(first_vals)):
        # fun note here is ** > - in priority, so -1 needs to be in parens
        q2_sum += int(first_vals[i] * (-1) ** i)
    return q2_sum

fn main() raises:
    let inpt = Path('./day9/input.txt').read_text().split('\n')

    var q2_sum = 0
    for i in range(len(inpt)):
        let seq_str = inpt[i].split(' ')
        var seq = DynamicVector[Int]()
        for i in range(len(seq_str)):
            seq.push_back(atol(seq_str[i]))

        q2_sum += get_first_value(seq)
    
    print(q2_sum)