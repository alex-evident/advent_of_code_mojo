from pathlib import Path
from python import Python

fn get_options_for_race(race: Tuple[Int, Int]) -> Int:
    var valid_options = 0
    for i in range(race.get[0, Int]()):
        let p_distance = (race.get[0, Int]() - i) * i
        if p_distance > race.get[1, Int]():
            valid_options += 1
    return valid_options

fn mainQ1() raises:
    # get times and distances
    let inpt = Path('./day6/input.txt').read_text().split('\n')
    let t_str = inpt[0]
    let d_str = inpt[1]

    # going to split out the race info by regex
    let re = Python.import_module('re')
    let t_split = re.split(r"\s+", t_str)
    let d_split = re.split(r"\s+", d_str)

    # first element is the "Time"/"Distance" strings, skip those - a zip func would be nice
    var race_options = SIMD[DType.int32, 32](1)
    for i in range(1, t_split.__len__()):
        let t = atol(str(t_split[i]))
        let d = atol(str(d_split[i]))
        race_options[i-1] = get_options_for_race((t, d))

    print(race_options.reduce_mul())

fn main() raises:
    # I'm sure there's a smart way of doing this that just finds the min and
    # max but the problem isn't perf intensive so...
    let inpt = Path('./day6/input.txt').read_text().split('\n')
    let time = atol(inpt[0].split(':')[1].replace(' ', ''))
    let dist = atol(inpt[1].split(':')[1].replace(' ', ''))
    print(get_options_for_race((time, dist)))