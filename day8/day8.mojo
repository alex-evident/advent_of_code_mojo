from pathlib.path import Path
from python import Python, PythonObject
from math import lcm

fn mainQ1() raises:
    let inpt = Path('./day8/input.txt').read_text().split('\n')
    let instruction_str = inpt[0]
    let num_instr = len(instruction_str)
    var instructions = DynamicVector[String]()
    for i in range(num_instr):
        instructions.push_back(instruction_str[i])

    # Mojo dict can't take tuple values, so we need two :|
    let l_dirs = Python.dict()
    let r_dirs = Python.dict()
    let bt = Python.import_module('builtins')

    # parse the map

    for i in range(2, len(inpt)):
        let map_line = inpt[i].split(' = ')
        let dirs = map_line[1].split(', ')
        l_dirs[map_line[0]] = dirs[0][1:]
        r_dirs[map_line[0]] = dirs[1][0:3]
    
    # iterate over the instructions
    var finished = True
    var idx = 0
    var loc: String = 'AAA'
    let end_loc: String = 'ZZZ'
    print("starting the journey! Going from", loc, '->', end_loc, 'with', num_instr, 'steps')
    while finished:
        # take next step
        let instr = instructions[idx % num_instr]
        if instr == 'R':
            # print("R:", loc, '->', r_dirs[loc])
            loc = str(r_dirs[loc])
        else:
            # print("L:", loc, '->', l_dirs[loc])
            loc = str(l_dirs[loc])

        # check for completion
        if loc == end_loc:
            finished = False
            break

        # keep going
        idx += 1

    print('done in', idx+1, 'steps')

fn main() raises:
    let inpt = Path('./day8/input.txt').read_text().split('\n')
    let instruction_str = inpt[0]
    let num_instr = len(instruction_str)
    var instructions = DynamicVector[String]()
    for i in range(num_instr):
        instructions.push_back(instruction_str[i])

    # Mojo dict can't take tuple values, so we need two :|
    let l_dirs = Python.dict()
    let r_dirs = Python.dict()
    let bt = Python.import_module('builtins')

    # parse the map
    var locs = DynamicVector[String]()
    var periods = DynamicVector[Int]()
    for i in range(2, len(inpt)):
        let map_line = inpt[i].split(' = ')
        let node = map_line[0]
        let dirs = map_line[1].split(', ')
        l_dirs[node] = dirs[0][1:]
        r_dirs[node] = dirs[1][0:3]

        # get the starting positions
        if node[2] == 'A':
            locs.push_back(node)
            periods.push_back(0)

    # iterate over the instructions - we want to find the period of each nodes path
    var idx = 0
    var finished_count = 0
    print('Starting with', len(locs), 'ghosts')
    while True:
        for i in range(len(locs)):
            let loc = locs[i]
            # take next step
            let instr = instructions[idx % num_instr]
            if instr == 'R':
                locs[i] = str(r_dirs[loc])
            else:
                locs[i] = str(l_dirs[loc])

            # check for completion
            if locs[i][2] == 'Z':
                # if this is the first time this ghost has reached a Z,
                # we store the number of the step, and increment the finished
                # counter - once all ghosts have finished at least once we're done
                if periods[i] == 0:
                    periods[i] = idx + 1 # increment before saving!
                    finished_count += 1

        if finished_count == len(locs):
            break

        # go again
        idx += 1

    var outpt = 1
    for i in range(len(periods)):
        outpt = lcm(outpt, periods[i])
    print(outpt)
