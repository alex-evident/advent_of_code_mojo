from pathlib.path import Path
from python import Python, PythonObject
from utils.index import Index
from memory import memset_zero
from algorithm import vectorize, parallelize
from sys.intrinsics import strided_load
from math import trunc, mod

# shapes:
# | vert pipe
# - horiz pipe
# L 90deg N/E
# J 90deg N/W
# 7 90deg S/W
# F 90deg S/E
# S start
# . empty

fn ix_to_x_y(ix:Int, row_count:Int, col_count:Int) -> StaticTuple[2, Int]:
    let y = ix // (col_count + 1)
    let x = ix % (row_count + 1)
    return StaticTuple[2, Int](x, y)

fn get_char(xy: SIMD, map: Tensor) -> String:
    return chr(int(map[Index(xy[1], xy[0])]))

fn get_next(xy: SIMD, map: Tensor, dir: String) -> Tuple[StringLiteral, SIMD[DType.float64, 2]]:
    # return the position of the next component in the loop
    # as far as I know strings are the only data structure in 
    # mojo which easily allow for testing membership, so that's what I'll use :)
    let x = xy[0]
    let y = xy[1]
    var polarity = SIMD[DType.float64, 2]() # 0 is the vertical matrix, 1 is the horizontal matrix
    let symbol = chr(int(map[Index(y, x)]))
    var new_dir: StringLiteral = ''
    if symbol == '-':
        if dir == 'right':
            new_dir = 'right'
            polarity[1] = 1
        else:
            new_dir = 'left'
            polarity[1] = -1
    elif symbol == '|':
        if dir == 'up':
            new_dir = 'up'
            polarity[0] = -1
        else:
            new_dir = 'down'
            polarity[0] = 1
    elif symbol == 'L':
        if dir == 'down':
            new_dir = 'right'
            polarity[0] = 0.5
            polarity[1] = 0.5
        else:
            new_dir = 'up'
            polarity[0] = -0.5
            polarity[1] = -0.5
    elif symbol == 'J':
        if dir == 'down':
            new_dir = 'left'
            polarity[0] = 0.5
            polarity[1] = -0.5
        else:
            new_dir = 'up'
            polarity[0] = -0.5
            polarity[1] = 0.5
    elif symbol == '7':
        if dir == 'up':
            new_dir = 'left'
            polarity[0] = -0.5
            polarity[1] = -0.5
        else:
            new_dir = 'down'
            polarity[0] = 0.5
            polarity[1] = 0.5
    elif symbol == 'F':
        if dir == 'up':
            new_dir = 'right'
            polarity[0] = -0.5
            polarity[1] = 0.5
        else:
            new_dir = 'down'
            polarity[0] = 0.5
            polarity[1] = -0.5
    elif symbol == 'S':
        # S in input is going -> ^
        polarity[0] = -0.5
        polarity[1] = 0.5
        new_dir = 'DONE'

    return new_dir, polarity


fn leftsum(xy: SIMD, map: Tensor) -> Float64:
    let x = xy[0]
    let y = xy[1]
    var sum: Float64 = 0
    if x == 0:
        return 0
    for i in range(int(x)):
        sum += map[Index(y, i)].cast[DType.float64]()
    return sum

fn rightsum(xy: SIMD, map: Tensor) -> Float64:
    let x = xy[0]
    let y = xy[1]
    var sum: Float64 = 0
    # go to the right
    if x == map.shape()[0]:
        return 0
    for i in range(int(x)+1, map.shape()[0]):
        sum += map[Index(y, i)].cast[DType.float64]()
    return sum

fn topsum(xy: SIMD, map: Tensor) -> Float64:
    let x = xy[0]
    let y = xy[1]
    var sum: Float64 = 0
    if y == 0:
        return 0
    for i in range(int(y)):
        sum += map[Index(i, x)].cast[DType.float64]()
    return sum

fn bottomsum(xy: SIMD, map: Tensor) -> Float64:
    let x = xy[0]
    let y = xy[1]
    var sum: Float64 = 0
    # go to the right
    if y == map.shape()[0]:
        return 0
    for i in range(int(y)+1, map.shape()[1]):
        sum += map[Index(i, x)].cast[DType.float64]()
    return sum


fn is_inside(xy: SIMD[DType.int16], vert_loop: Tensor, horiz_loop: Tensor) -> Bool:
    let rsum = rightsum(xy, vert_loop)
    let lsum = leftsum(xy, vert_loop)
    let tsum = topsum(xy, horiz_loop)
    let bsum = bottomsum(xy, horiz_loop)
    var flag = True
    if xy[0] == 2 and xy[1] == 8:
        print('rsum: ', rsum)
        print('lsum: ', lsum)
        print('tsum: ', tsum)
        print('bsum: ', bsum)
    # if there are no loop components in any direction
    # then we're not within the loop
    if (rsum == 0) or (lsum == 0) or (tsum == 0) or (bsum == 0):
        flag = False
    # if all the sums are even then we're not within the loop
    elif ((rsum % 2) == 0) and ((lsum % 2) == 0) and ((tsum % 2) == 0) and ((bsum % 2) == 0):
        flag = False
    if flag:
        print('position', '(', xy[0], xy[1], ')', flag)
    return flag

fn main() raises:
    let inpt = Path('./day10/input.txt').read_text()
    let row_count = len(inpt.split('\n'))
    let col_count = len(inpt.split('\n')[0])
    # get start
    let start_ix = inpt.find('S')
    let start_xy = ix_to_x_y(start_ix, row_count, col_count)

    # can't have a tensor of chars :)
    var map = Tensor[DType.int16](row_count, col_count)
    # fill array
    for i in range(len(inpt)):
        if (i + 1) % (col_count + 1) == 0:
            continue
        let xy = ix_to_x_y(i, row_count, col_count)
        let val = ord(inpt[i])
        map[Index(xy[1], xy[0])] = val
    
    var xy = SIMD[DType.int16, 2](start_xy[0], start_xy[1])
    var dir: String = 'right'
    var polarity = SIMD[DType.float64, 2]()

    var loop = Tensor[DType.float64](row_count, col_count)
    var vert_loop = Tensor[DType.float64](row_count, col_count)
    var horiz_loop = Tensor[DType.float64](row_count, col_count)
    print('starting at pos', xy)
    for i in range(100_000):
        let old_char = get_char(xy, map)
        # hacky - should check around S to find which direction to travel
        # but I've already spent ages on this problem so ¯\_(ツ)_/¯
        if i == 0:
            dir = 'up'
        else:
            let result = get_next(xy, map, dir)
            polarity = result.get[1, SIMD[DType.float64, 2]]()
            dir = result.get[0, StringLiteral]()

        loop[Index(xy[1], xy[0])] = 1
        vert_loop[Index(xy[1], xy[0])] = polarity[0]
        horiz_loop[Index(xy[1], xy[0])] = polarity[1]
            # you need two crooked shapes for one movement in either direction
            # so they count for 0.5 for our summing purposes.
            # if they are going right/down that's +ve, left/up is -ve
            # TODO: IMPLEMENT THIS HELLISH LOGIC
            # fex. if F says down,  it's +0.5 vert, -0.5 horiz
            # #      if F says right, it's -0.5 vert, +0.5 horiz
            # vert_loop[Index(xy[1], xy[0])] = 0.5
            # horiz_loop[Index(xy[1], xy[0])] = 0.5

        if dir == 'up':
            xy[1] += -1
            vert_loop[Index(xy[1], xy[0])] = -1
        elif dir == 'down':
            xy[1] += 1
            vert_loop[Index(xy[1], xy[0])] = 1
        elif dir == 'left':
            xy[0] += -1
            horiz_loop[Index(xy[1], xy[0])] = -1
        elif dir == 'right':
            xy[0] += 1
            horiz_loop[Index(xy[1], xy[0])] = 1
        elif dir == 'DONE':
            print("DONE")
            break
        if i > 90_000:
            print('uh oh')
            break
    
    print(loop)

    # now we've built up the vertical and horizontal representations of the loop, we iterate over
    # each element in the tensor and check if it's contained within the loop

    var inside_count = 0
    for i in range(row_count):
        for j in range(col_count):
            let tile_xy = SIMD[DType.int16](j, i)
            # if the point is on the loop, continue
            if loop[Index(i, j)] == 1:
                # print('skipping', j, i)
                continue

            # otherwise check if it's outside
            if is_inside(tile_xy, vert_loop, horiz_loop):
                inside_count += 1
    print(inside_count)
    # print(vert_loop)
    # print(horiz_loop)