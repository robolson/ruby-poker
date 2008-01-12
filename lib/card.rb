class PokerHand
  
  class Card
    include Comparable
    attr_reader :suit, :value

    def initialize card_str
      card_str = card_str.gsub("T","10").gsub("J","11").gsub("Q","12").gsub("K","13").gsub("A","14")
      @value = card_str[0, card_str.length-1].to_i
      @suit = card_str[-1,1]
    end

    def <=> card2
      @value <=> card2.value
    end

    def to_s
      @value.to_s + @suit
    end
  end # class Card
  
end # class PokerHand