from pathlib.path import Path

fn compute_matches(pcards: DynamicVector[String], wcards: DynamicVector[String]) -> Int:
    var matches = 0

    for j in range(len(pcards)):
        let player_card = pcards[j]
        # string split returns the empty strings at the start/end, so skip
        for k in range(1, len(wcards) - 1):
            let winning_card = wcards[k]
            if winning_card == player_card:
                matches += 1

    return matches

fn main() raises:
    let games = Path('./day4/input.txt').read_text().split('\n')

    # I don't think this is how you're meant to use SIMD but it does give
    # nice init to all 0s and a convenient summing method...
    var card_counts = SIMD[DType.int32, 256]()
    var q1_sum = 0
    for i in range(len(games)):
        card_counts[i] += 1
        let game = games[i]
        # remove double spaces to keep split sane
        let pcards = game.split('|')[1].replace('  ', ' ').split(' ')
        let wcards = game.split(':')[1].split('|')[0].replace('  ', ' ').split(' ')
        let matches = compute_matches(pcards, wcards)
        if matches:
            q1_sum += 2 ** (matches - 1)

        # for a downstream card, increment its ref count by the number of
        # references to the current card
        for m in range(matches):
            card_counts[i + 1 + m] += card_counts[i]

    print('Q1:', q1_sum)
    print('Q2:', card_counts.reduce_add())
