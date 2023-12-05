# from python import Python, PythonObject
from pathlib import Path
from math import min

fn parse_map(map_str: String) raises -> DynamicVector[Tuple[Int, Int, Int]]:
    let map_ranges = map_str.split('\n')
    var maps_out = DynamicVector[Tuple[Int, Int, Int]]()
    # we create a vector containing tuples of the start, end, diff


    # skip first element, which describes what the map is
    for i in range(1, len(map_ranges)):
        let vals = map_ranges[i].split(' ')
        let range_start = atol(vals[1])
        let range_end = atol(vals[1]) + atol(vals[2])
        let diff = atol(vals[0]) - atol(vals[1])
        maps_out.push_back((range_start, range_end, diff))

    return maps_out

fn mutate_seed(inout seed: Int, maps: DynamicVector[Tuple[Int, Int, Int]]):
    # If the input is between the start and end of any range, change it by the diff
    # if not, return it
    for i in range(len(maps)):
        let start = maps[i].get[0, Int]()
        let end = maps[i].get[1, Int]()
        if start <= seed < end:
            seed += maps[i].get[2, Int]()
            return # return here to prevent multiple mutations

fn mainQ1() raises:
    let inpt = Path('./day5/input.txt').read_text().split('\n\n')
    let seed_strs = inpt[0].split(': ')[1].split(' ')

    # store the seeds we'll be passing through the maps
    var seeds = DynamicVector[Int]()
    for i in range(len(seed_strs)):
        seeds.push_back(atol(seed_strs[i]))

    # iterates over the maps
    for i in range(1, len(inpt)):
        print('')
        # get the maps for the given step, then pass the seeds through them
        let map = parse_map(inpt[i])
        for j in range(len(seeds)):
            mutate_seed(seeds[j], map)
    

    var min_val: Int = 0
    for i in range(len(seeds)):
        if i ==0:
            min_val += seeds[i]

        min_val = min(min_val, seeds[i])
    
    print(min_val)

fn main() raises:
    let inpt = Path('./day5/input.txt').read_text().split('\n\n')
    let seed_strs = inpt[0].split(': ')[1].split(' ')

    # store the seeds we'll be passing through the maps
    # for Q2, all we need to do is build the list of seeds differently by striding
    # across the range
    var seeds = DynamicVector[Int]()
    for i in range(0, len(seed_strs), 2):
        let start = atol(seed_strs[i])
        let end = start + atol(seed_strs[i+1])
        for j in range(start, end):
            seeds.push_back(j)

    # iterates over the maps. Note this is slow as all hell, thank god
    # I'm writing it in Mojo not Python
    for i in range(1, len(inpt)):
        print('Starting on map', i)
        # get the maps for the given step, then pass the seeds through them
        let map = parse_map(inpt[i])
        for j in range(len(seeds)):
            mutate_seed(seeds[j], map)


    print('Getting min value')
    var min_val: Int = 0
    for i in range(len(seeds)):
        if i ==0:
            min_val += seeds[i]

        min_val = min(min_val, seeds[i])
    
    print(min_val)