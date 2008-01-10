module Rank
  HIGH_CARD = 0
  PAIR = 1
  TWO_PAIR = 2
  THREE_OF_A_KIND = 3
  STRAIGHT = 4
  FLUSH = 5
  FULL_HOUSE = 6
  FOUR_OF_A_KIND = 7
  STRAIGHT_FLUSH = 8
  ROYAL_FLUSH = 9
  
  def self.verbose status_num
    case status_num
      when 0: "High Card"
      when 1: "Pair"
      when 2: "Two Pair"
      when 3: "Three of a Kind"
      when 4: "Straight"
      when 5: "Flush"
      when 6: "Full House"
      when 7: "Four of a Kind"
      when 8: "Straight Flush"
      when 9: "Royal Flush"
    end
  end
end