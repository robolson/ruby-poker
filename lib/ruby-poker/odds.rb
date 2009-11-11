require File.join(File.dirname(__FILE__), 'mathpc')

module PokerOdds
  module HoldEm
    @cards_max = 7
    @preflop_denom = 52.c(2)
    @flop_denom = 52.c(5)
    @turn_denom = 52.c(6)
    @river_denom = 52.c(7)

    def self.next_card(good, seen)
      bad = 52 - seen
      odds = good.to_f/bad.to_f
    end

    def self.by_river(good)
      turn = next_card(good, 5)
      river = next_card(good, 6)
      turn + river
    end

    def self.pair(have, to_come=nil)
      to_come ||= @cards_max - PokerHand.new(known).length
      total_cards = 52 - PokerHand.new(have).length
    end

    def self.odds(needed, known, to_come=nil)
      (needed.to_f / (52 - known).to_f)
    end
  end
end

if __FILE__ == $0
  puts "one card:"
  puts "- odds 4 flush completing: #{PokerOdds::HoldEm.next_card(9, 5)}"
  puts "two cards:"
  puts "- odds 4 flush completing: #{PokerOdds::HoldEm.by_river(9)}"
end
