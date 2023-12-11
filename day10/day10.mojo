from pathlib.path import Path
from python import Python, PythonObject
from utils.index import Index

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

fn get_next(xy: SIMD, map: Tensor, dir: String) -> String:
    # return the position of the next component in the loop
    # as far as I know strings are the only data structure in 
    # mojo which easily allow for testing membership, so that's what I'll use :)
    let x = xy[0]
    let y = xy[1]
    let symbol = chr(int(map[Index(y, x)]))
    var new_dir: String = ''
    if symbol == '-':
        if dir == 'right':
            new_dir = 'right'
        else:
            new_dir = 'left'
    elif symbol == '|':
        if dir == 'up':
            new_dir = 'up'
        else:
            new_dir = 'down'
    elif symbol == 'L':
        if dir == 'down':
            new_dir = 'right'
        else:
            new_dir = 'up'
    elif symbol == 'J':
        if dir == 'down':
            new_dir = 'left'
        else:
            new_dir = 'up'
    elif symbol == '7':
        if dir == 'up':
            new_dir = 'left'
        else:
            new_dir = 'down'
    elif symbol == 'F':
        if dir == 'up':
            new_dir = 'right'
        else:
            new_dir = 'down'
    elif symbol == 'S':
        new_dir = 'DONE'

    return new_dir


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
    
    var xy = SIMD[DType.int16](start_xy[0], start_xy[1])
    var dir: String = 'right'

    var total_steps = 0
    for i in range(100_000):
        let old_char = get_char(xy, map)
        
        # hacky - should check around S to find which direction to travel
        # but I've already spent ages on this problem so ¯\_(ツ)_/¯
        if i == 0:
            dir = 'up'
        else:
            dir = get_next(xy, map, dir)

        var arrw: String = ''
        if dir == 'up':
            xy[1] += -1
            arrw = '↑'
        elif dir == 'down':
            xy[1] += 1
            arrw = '↓'
        elif dir == 'left':
            xy[0] += -1
            arrw = '<-'
        elif dir == 'right':
            xy[0] += 1
            arrw = '->'
        elif dir == 'DONE':
            print("DONE")
            break

        total_steps += 1
        print(i+1, ':', old_char, arrw, get_char(xy, map))
    print('furthest point:', total_steps//2)