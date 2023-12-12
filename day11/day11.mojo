from python.python import Python
from pathlib.path import Path
from math import abs
from utils.index import Index


fn ix_to_x_y(ix:Int, row_count:Int, col_count:Int) -> StaticTuple[2, Int]:
    let y = ix // (col_count + 1)
    let x = ix % (row_count + 1)
    return StaticTuple[2, Int](x, y)

fn get_distance(combination: PythonObject) raises -> Int:
    # this is a manhattan space with no angled movement
    # the shortest distance between two points is |x2-x1| + |y2-y1|
    let a = combination[0]
    let b = combination[1]
    let d = (a[0] - b[0]).__abs__() + (a[1] - b[1]).__abs__()
    return int(d)

# The logic here is constructing a python set of all possible index values (0->max_index)
# we then check each galaxy and remove the corresponding coords from our set - this gives
# the row/column indices which will be expanded
# I did this in one function, but after spending half an hour trying to return and unpack 2 tuples I capitulated.
# I'm just writing two extremely redundant functions before I lose my mind...
fn get_horiz_expansions(combinations: PythonObject, col_count: Int) raises -> PythonObject:
    var c = combinations
    let bt = Python.import_module('builtins')
    let horiz_set = bt.set()
    for i in range(col_count):
        let __ = horiz_set.add(i)
    for comb in c:
        let y = comb[1]
        let __ = horiz_set.discard(y)
    return horiz_set
fn get_vert_expansions(combinations: PythonObject, row_count: Int) raises -> PythonObject:
    var c = combinations
    let bt = Python.import_module('builtins')
    let vert_set = bt.set()
    for i in range(row_count):
        let __ = vert_set.add(i)
    for comb in c:
        let x = comb[0]
        let __ = vert_set.discard(x)
    return vert_set

fn main() raises:
    # This approach is a naive implementation - taking the distance between all pairs of galaxy coordinates.
    # takes a few seconds to run
    let iter = Python.import_module('itertools')
    let bt = Python.import_module('builtins')
    let inpt = Path('./day11/input.txt').read_text()
    let row_count = len(inpt.split('\n'))
    let col_count = len(inpt.split('\n')[0])

    var galaxy_coords = PythonObject([])
    # fill array
    for i in range(len(inpt)):
        if inpt[i] == '#':
            let xy = ix_to_x_y(i, row_count, col_count)
            let __ = galaxy_coords.append(PythonObject(((xy[0], xy[1]))))

    # get the rows and cols which are to be "expanded"
    var vs = bt.list(get_vert_expansions(galaxy_coords, row_count))
    var hs = bt.list(get_horiz_expansions(galaxy_coords, col_count))

    # go over each galaxy coordinate and update it to reflect our coord expansion
    let all_coords_expanded = PythonObject([])
    for coords in galaxy_coords:
        var x = int(coords[0])
        var y = int(coords[1])
        for vertical_threshold in vs:
            if coords[0] > vertical_threshold:
                x += 1_000_000 - 1 # for Q1 just set these to += 1
        for horizontal_threshold in hs:
            if coords[1] > horizontal_threshold:
                y += 1_000_000 - 1
        
        let expanded_coords = PythonObject((x, y))
        let __ = all_coords_expanded.append(expanded_coords)


    # get every pair of galaxies and their distances
    var combs = iter.combinations(all_coords_expanded, 2)
    var total_distance = 0
    var l = 0
    for comb in combs:
        l += 1
        total_distance += get_distance(comb)

    print(total_distance)