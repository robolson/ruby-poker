# Instructions:
#
# Download 'poker-hand-testing.data' dataset from http://archive.ics.uci.edu/ml/datasets/Poker+Hand.
# Execute this script with path to the data file as the first argument.
#
# bundle exec ruby test/integration/test_a_million_hands.rb ~/Downloads/poker-hand-testing.data

# Attribute information for poker-hand-testing.data
#
# Attribute Information:
#
# 1) S1 "Suit of card #1"
# Ordinal (1-4) representing {Hearts, Spades, Diamonds, Clubs}
#
# 2) C1 "Rank of card #1"
# Numerical (1-13) representing (Ace, 2, 3, ... , Queen, King)
#
# 3) S2 "Suit of card #2"
# Ordinal (1-4) representing {Hearts, Spades, Diamonds, Clubs}
#
# 4) C2 "Rank of card #2"
# Numerical (1-13) representing (Ace, 2, 3, ... , Queen, King)
#
# 5) S3 "Suit of card #3"
# Ordinal (1-4) representing {Hearts, Spades, Diamonds, Clubs}
#
# 6) C3 "Rank of card #3"
# Numerical (1-13) representing (Ace, 2, 3, ... , Queen, King)
#
# 7) S4 "Suit of card #4"
# Ordinal (1-4) representing {Hearts, Spades, Diamonds, Clubs}
#
# 8) C4 "Rank of card #4"
# Numerical (1-13) representing (Ace, 2, 3, ... , Queen, King)
#
# 9) S5 "Suit of card #5"
# Ordinal (1-4) representing {Hearts, Spades, Diamonds, Clubs}
#
# 10) C5 "Rank of card 5"
# Numerical (1-13) representing (Ace, 2, 3, ... , Queen, King)
#
# 11) CLASS "Poker Hand"
# Ordinal (0-9)
#
# 0: Nothing in hand; not a recognized poker hand
# 1: One pair; one pair of equal ranks within five cards
# 2: Two pairs; two pairs of equal ranks within five cards
# 3: Three of a kind; three equal ranks within five cards
# 4: Straight; five cards, sequentially ranked with no gaps
# 5: Flush; five cards with the same suit
# 6: Full house; pair + different rank three of a kind
# 7: Four of a kind; four equal ranks within five cards
# 8: Straight flush; straight + flush
# 9: Royal flush; {Ace, King, Queen, Jack, Ten} + flush

require 'rubygems'
require 'bundler/setup'
require 'ruby-poker'

SUITS = ['H', 'S', 'D', 'C']

data_file = ARGV[0]

puts data_file

File.new(data_file).each do |line|
  columns = line.split(',')

  expected_rank = columns.delete_at(10).to_i

  cards = []
  columns.each_slice(2) do |suit, face_value|

    # The translations below come from the ordering of suits within the Card class
    rp_suit = case suit.to_i
    when 1 # Hearts
      2
    when 2 # Spades
      3
    when 3 # Diamonds
      1
    when 4 # Clubs
      0
    end

    rp_face_value = face_value.to_i - 1
    # in ruby-poker Aces have the highest value
    rp_face_value = 13 if rp_face_value == 0

    cards << ::RubyPoker::Card.new(rp_face_value, rp_suit)
  end

  hand = ::RubyPoker::PokerHand.new(cards)
  score = hand.score[0][0]  # don't know what was I thinking with this double nested array

  if score - 1 != expected_rank
    puts "Inconsistency found in: #{line}"
  end
end
