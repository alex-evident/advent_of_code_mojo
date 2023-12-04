from python import Python, PythonObject
from math import max

fn get_id(row: PythonObject, re: PythonObject) raises -> Int:
    let mo = re.search(r"Game (\d+):.*", row)
    let game_num = mo.groups()[0].__str__()
    return atol(game_num)

fn game_is_possible(row: PythonObject, re: PythonObject) raises -> Bool:
    # I can't get typing to work for Dictionary type, so
    # just going to declare this in every iteration...
    let maxvals = Python.dict()
    maxvals['r'] = 12
    maxvals['g'] = 13
    maxvals['b'] = 14

    let colour_info = re.split(': ', row)[1]
    var colour_strs = re.split(',|; ', colour_info)

    for colour_str in colour_strs:
        let grps = re.search(r"(\d+) (\w+)", colour_str).groups()
        let col = grps[1][0]
        let cnt = atol(grps[0].__str__())
        if cnt > maxvals[col].to_float64().to_int():
            return False
    return True



fn mainQ1() raises:
    let test_str = """Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"""

    let input: String
    with open("day2/input.txt", "r") as f:
        input = f.read()

    # split into rows
    let re = Python.import_module('re')
    var rows = re.split(r"\n", input)
    var total_sum = 0
    for row in rows:
        if game_is_possible(row, re):
            total_sum += get_id(row, re)

    print(total_sum)


fn get_set_power(row: PythonObject, re: PythonObject) raises -> Int:
    let vals = Python.dict()
    let colour_info = re.split(': ', row)[1]
    var colour_strs = re.split(',|; ', colour_info)

    for colour_str in colour_strs:
        let grps = re.search(r"(\d+) (\w+)", colour_str).groups()
        let col = grps[1][0]
        let cnt = atol(grps[0].__str__())
        vals[col] = max(cnt, vals.get(col, 0).to_float64().to_int())

    let power = vals.get('r', 0) * vals.get('g', 0) * vals.get('b', 0)
    return power.to_float64().to_int()

fn main() raises:
    let inpt: String
    with open("day2/input.txt", "r") as f:
        inpt = f.read()

    # split into rows
    let re = Python.import_module('re')
    var rows = re.split(r"\n", inpt)
    var total_sum = 0
    for row in rows:
        total_sum += get_set_power(row, re)

    print(total_sum)