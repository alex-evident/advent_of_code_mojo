from python import Python, PythonObject
from pathlib.path import Path
from algorithm import sort

fn get_hand_power(hand: String) raises -> String:
    # represent a hand as an int so we can easily compare hands
    # first digit is the value of the type of hand (5 of a kind etc...)
    # each card after that is boiled down into 2 digits from 12->01
    # then concat and return
    let bt = Python.import_module('builtins')
    let coll = Python.import_module('collections')
    let c = coll.Counter(hand)
    let vals = bt.list(c.values())

    let card_power: String
    if vals.__contains__(5): # 5 of a kind
        card_power = '9'
    elif vals.__contains__(4): # 4 of a kind
        card_power = '8'
    elif vals.__contains__(3) and vals.__contains__(2): # full house
        card_power = '7'
    elif vals.__contains__(3): # 3 of a kind
        card_power = '6'
    elif vals.count(2) == 2: # 2 pair
        card_power = '5'
    elif vals.__contains__(2): # 1 pair
        card_power = '4'
    else:
        card_power = '3'

    return card_power

fn try_all_j_options(hand: String) raises -> Int:
    let j_opts = VariadicList("A", "K", "Q", "T", "9", "8", "7", "6", "5", "4", "3", "2", "1")

    var card_power: String = '0'
    var max_power: Int = 0
    for i in range(len(j_opts)):
        let hand_opt = hand.replace('J', j_opts[i])
        let hand_power = get_hand_power(hand_opt)
        if atol(hand_power) > max_power:
            card_power = hand_power
            max_power = atol(hand_power)

    # iterate over the cards and append to the string
    for i in range(len(hand)):
        let ch = hand[i]
        if ch == 'A':
            card_power += '14'
        elif ch == 'K':
            card_power += '13'
        elif ch == 'Q':
            card_power += '12'
        elif ch == 'J':
            card_power += '00'
        elif ch == 'T':
            card_power += '10'
        else:
            card_power += ('0' + ch)

    return atol(card_power)



fn main() raises:
    let inpt = Path('./day7/input.txt').read_text().split('\n')
    let bt = Python.import_module('builtins')
    let num_hands = len(inpt)

    # need to use builtin dict to comply with Python's sorted func
    let hands = bt.dict()
    for i in range(len(inpt)):
        let split = inpt[i].split(' ')
        let hand = try_all_j_options(split[0])
        let bid = atol(split[1])
        let __ = hands.__setitem__(hand, bid) # just assigning to suppress compiler warning

    let hands_sorted = bt.list(bt.reversed(bt.sorted(hands)))

    var total_val = 0
    for i in range(hands_sorted.__len__()):
        let s_hand = hands_sorted[i]
        total_val += int(hands[s_hand]) * (num_hands - i)

    print(total_val)