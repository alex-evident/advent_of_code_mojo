from tensor import Tensor, TensorSpec, TensorShape
from pathlib import Path
from math import min, max

fn ispart(char: String) -> Bool:
    # id dot
    if ord(char) == 46 or isdigit(ord(char)):
        return False
    return True

fn check_vicinity(rows: DynamicVector[String], i: Int, j: Int, max_i: Int, max_j: Int) -> Int:
    # This feels not good
    let left_safe = j > 0
    let right_safe = j < max_j - 1
    let top_safe = i > 0
    let bottom_safe = i < max_i - 1

    if right_safe and ispart(rows[i][j+1]):
        return 1
    if right_safe and bottom_safe and ispart(rows[i+1][j+1]):
        return 1
    if right_safe and top_safe and ispart(rows[i-1][j+1]):
        return 1
    if left_safe and ispart(rows[i][j-1]):
        return 1
    if left_safe and top_safe and ispart(rows[i-1][j-1]):
        return 1
    if left_safe and bottom_safe and ispart(rows[i+1][j-1]):
        return 1
    if top_safe and ispart(rows[i-1][j]):
        return 1
    if bottom_safe and ispart(rows[i+1][j]):
        return 1
    return 0

fn update_min_max(digits: Tensor[DType.int32], inout min_digit: Int, inout max_digit: Int, i: Int, j: Int):
    if digits[i, j] == 0:
        return
    
    min_digit = min(min_digit, digits[i, j].to_int())
    max_digit = max(max_digit, digits[i, j].to_int())


fn get_gear_score(digits: Tensor[DType.int32], i: Int, j: Int, max_i: Int, max_j: Int) -> Int:
    # Forgive me father for I have sinned
    let left_safe = j > 0
    let right_safe = j < max_j - 1
    let top_safe = i > 0
    let bottom_safe = i < max_i - 1

    var min_digit = 10000000
    var max_digit = 0
    if right_safe:
        update_min_max(digits, min_digit, max_digit, i, j+1)
    if right_safe and bottom_safe:
        update_min_max(digits, min_digit, max_digit, i+1, j+1)
    if right_safe and top_safe:
        update_min_max(digits, min_digit, max_digit, i-1, j+1)
    if left_safe:
        update_min_max(digits, min_digit, max_digit, i, j-1)
    if left_safe:
        update_min_max(digits, min_digit, max_digit, i-1, j-1)
    if left_safe and bottom_safe:
        update_min_max(digits, min_digit, max_digit, i+1, j-1)
    if top_safe:
        update_min_max(digits, min_digit, max_digit, i-1, j)
    if bottom_safe:
        update_min_max(digits, min_digit, max_digit, i+1, j)
    
    # not robust to same number on either side of a gear, that would req keeping track of gaps
    # between nums...
    print('min', min_digit, 'max', max_digit, 'at pos', i, j)
    if min_digit == max_digit:
        return 0
    return min_digit * max_digit

fn main() raises:
    let rows = Path('./day3/input.txt').read_text().split('\n')

    let w = len(rows[0])
    let h = len(rows)

    # We're going to store the values in a tensor so we can 
    # ref them later    
    let spec = TensorSpec(DType.int32, w, h)
    var digits = Tensor[DType.int32](spec)

    var q1_score = 0
    var current_num: String = ''
    var part_flag = 0
    print('unleash hell')
    for i in range(h):
        for j in range(w):
            # want to slice into the tensor at i-1:i+1, j-1:j+1
            # unfortunately Mojo tensors don't support 2d slicing, and 
            # slicing doesn't work in Python interop either.
            # instead we'll do it manually, with all the boundary checks :'(

            # if current char is not a digit, we check if the num in our buffer
            # touched a part, and save or remove it
            if not isdigit(ord(rows[i][j])):
                if current_num:
                    q1_score += part_flag * atol(current_num)
                    for k in range(len(current_num)):
                        # there must be a better way...
                        digits.__setitem__(VariadicList(i, j-k-1), SIMD[DType.int32, 1](atol(current_num)))
                    part_flag = 0
                    current_num = ''
                continue

            current_num += rows[i][j]
            # update flag for q1
            part_flag = max(part_flag, check_vicinity(rows, i, j, h, w))

    # now we iterate over the rows, and wherever we find an asterisk we check the adjacent cells in the tensor for
    # the nearby digits. We take the product of the min and max of these numbers to get the gear ratio
    var q2_score = 0
    for i in range(h):
        for j in range(w):
            if rows[i][j] == '*':
                print('going in')
                q2_score += get_gear_score(digits, i, j, h, w)
    print(q2_score)