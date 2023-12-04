from tensor import Tensor
from python import Python

def parse(s: String) -> Int:
    # 46 is the ord of a period. Below 46 -> Symbol, Above 46 -> digit
    val = ord(s) - 46
    if val <= 0:
        return 0
    elif val < 0:
        return -1
    else:
        return atol(s)
    

# going a bit more pythonic for this one
def main():
    let test_str: String = """467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."""

    # ord < 46

    # get the dimensions of the array - I've truncated the final newline in the input.txt
    row_count = test_str.count('\n') + 1
    col_count = test_str.find('\n')
    np = Python.import_module('numpy')
    # arr = np.empty((row_count, col_count), 'str')
    arr = Tensor[DType.int16](row_count, col_count, 1)

    # build the array which we'll index into later
    for i in range(row_count): 
        for j in range(col_count):
            # note we need to add another i on here to account for newlines
            idx = (i * (row_count + 1)) + j

            # arr[i,j] = ... style assignment not yet supported
            arr[i*row_count + j] = parse(test_str[idx])

    # padding the array so we don't have any weird slicing issues at the boundary
    # kwargs not yet supported :(
    # arr = np.pad(arr, 1, 'constant')

    # mojo builtin tensor doesn't support slicing, and you can't slice to python objects >:(
    print(arr)
    print(arr[0, 0:3])
    # print(arr.shape)
    # print(arr[0:2])