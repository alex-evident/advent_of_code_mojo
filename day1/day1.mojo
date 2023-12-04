from python import Python, PythonObject
from utils.vector import DynamicVector
from utils.static_tuple import StaticTuple

fn get_row_val(row_py: PythonObject) raises -> Int:
    let row = row_py.__str__()
    # Need to intialise these here so the compiler knows they'll be updated
    var first_int = 0
    var last_int = 0
    # first we iterate forwards. I'm relying on errors to check if the char is an int
    let row_len = len(row)
    for i in range(row_len):
        try:
            if first_int == 0:
                first_int = atol(row[i])
        except Error:
            pass

    for i in range(row_len):
        try:
            if last_int == 0:
                # negative index slicing not yet implemented, so this is the hack
                # when i=0, we get the last val
                last_int = atol(row[row_len-i-1])
            break
        except Error:
            pass
    
    let concat = String(first_int) + String(last_int)
    print(row, concat)
    return atol(concat)


fn main_Q1() raises:
    # since mojo doesn't have string split :'( we'll use Python's regex module
    # This will be a recurring theme...
    let re = Python.import_module('re')
    
    let test_str: String = """1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"""

    let inpt: String
    with open('./day1/input.txt', 'r') as f:
        inpt = f.read()

    var split_str = re.split(r"\n", inpt)
    var total_sum = 0
    print("Total elements", split_str.__len__())
    for row_py in split_str:
        total_sum += get_row_val(row_py)
    print(total_sum)

######################################################################
# Question 2 - string detection
# For Q2, we're going to have two dynamic vectors, one for digits and
# one for strings. We record the index of the values so we can later go
# back and pull out
fn str_to_int(input: String) -> Int:
    # first check for digits, then for words
    let digits = StaticTuple[10]("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
    let nums = StaticTuple[9]("one", "two", "three", "four", "five", "six", "seven", "eight", "nine")

    for i in range(digits.__len__()):
        if input[:1] == digits[i]:
            return i

    for i in range(nums.__len__()):
        if input[:len(nums[i])] == nums[i]:
            return i + 1

    # -1 is our "no hits" value
    return -1

fn main() raises:
    let input: String
    with open("day1/input.txt", "r") as f:
        input = f.read()

    var first_int= -1
    var last_int = 0
    var total_sum = 0

    for i in range(len(input)):
        # If it's a newline, add the value to the sum and move on
        if input[i] == "\n":
            total_sum += 10 * first_int + last_int
            first_int= -1
            continue
        # Check if there's a numeric text string or int at the given location
        let n = str_to_int(input[i:i + 5])
        if first_int < 0:
            first_int = last_int = n
        elif n >= 0:
            last_int = n

    print(total_sum)