from python import Python, PythonObject
from pathlib.path import Path
from algorithm import sort

fn get_hand_power(hand: String) raises -> Int:
    # represent a hand as an int so we can easily compare hands
    # first digit is the value of the type of hand (5 of a kind etc...)
    # each card after that is boiled down into 2 digits from 12->01
    # then concat and return
    let bt = Python.import_module('builtins')
    let coll = Python.import_module('collections')
    let c = coll.Counter(hand)
    let vals = bt.list(c.values())
    
    var card_power: String
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
    
    # now we iterate over the cards and append to the string
    for i in range(len(hand)):
        let ch = hand[i]
        if ch == 'A':
            card_power += '14'
        elif ch == 'K':
            card_power += '13'
        elif ch == 'Q':
            card_power += '12'
        elif ch == 'J':
            card_power += '11'
        elif ch == 'T':
            card_power += '10'
        else:
            card_power += ('0' + ch)

    return atol(card_power)



fn main() raises:
    let inpt = Path('./day7/input.txt').read_text().split('\n')
    let bt = Python.import_module('builtins')
    let num_hands = len(inpt)

    let hands = bt.dict()
    for i in range(len(inpt)):
        let split = inpt[i].split(' ')
        let hand = get_hand_power(split[0])
        let bid = atol(split[1])
        let __ = hands.__setitem__(hand, bid) # assignment to suppress compiler warning...

    let hands_sorted = bt.list(bt.reversed(bt.sorted(hands)))

    var total_val = 0
    for i in range(hands_sorted.__len__()):
        let s_hand = hands_sorted[i]
        total_val += int(hands[s_hand]) * (num_hands - i)

    print(total_val)