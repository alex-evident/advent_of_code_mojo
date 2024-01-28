from pathlib.path import Path

fn validate_row(block: String, info: DynamicVector[Int]) raises -> Bool:
    let block_split = block.split('.')
    # str split has loads of empty strings in it we need to remove
    var sections = DynamicVector[String]()
    for i in range(len(block_split)):
        if block_split[i]:
            sections.append(block_split[i])

    if len(info) != len(sections):
        return False

    for i in range(len(sections)):
        if sections[i].count('#') != info[i]:
            return False
    return True

def gen_options(block: String, info: DynamicVector[Int], i: Int) -> Int:
    if i == len(block):
        if validate_row(block, info):
            return 1
        else:
            return 0
    
    if block[i] == '?':
        return gen_options(block[:i] + '#' + block[i+1:], info, i+1) +
               gen_options(block[:i] + '.' + block[i+1:], info, i+1)
    else:
        return gen_options(block, info, i+1)

fn main() raises:
    let inpt = Path('./day12/input.txt').read_text().split('\n')
    # 1. write a function to test if a combination is valid
    # 2. build a string of values to use
    # 3. sum valid vals
    var blocks = DynamicVector[String]()
    var infos = DynamicVector[DynamicVector[Int]]()

    for i in range(len(inpt)):
        var info = DynamicVector[Int]()
        let b_i = inpt[i].split(' ')
        blocks.append(b_i[0])
        let info_split = b_i[1].split(',')
        for i in range(len(info_split)):
            info.append(atol(info_split[i]))
    
        infos.append(info)
    
    var total = 0
    for i in range(len(blocks)):
        print(i, inpt[i])
        total += gen_options(blocks[i], infos[i], 0)
    
    print(total)

    
    