require 'rubygems'
require 'ruby-poker'

hand1 = PokerHand.new("8H 9C TC JD QH")
hand2 = PokerHand.new(["3D", "3C", "3S", "KD", "AH"])
puts hand1
puts hand1.just_cards
puts hand1.rank
puts hand2
puts hand2.rank
puts hand1 > hand2
