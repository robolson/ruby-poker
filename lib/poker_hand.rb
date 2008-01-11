# poker_hand.rb

class Array
  # if any element occurs more than once in the array remove all occurances of that element
  # [1, 1, 2, 3] => [2, 3]
  def singles
    counts = Hash.new(0)
    self.each do |value|
      counts[value] += 1
    end

    return counts.collect {|key,value| value == 1 ? key : nil }.compact.sort
  end
  
  # Returns an array containing values that we duplicated in the original array
  # [1, 2, 3, 1] => [1]
  def duplicates
    counts = Hash.new(0)
    self.each do |value|
      counts[value] += 1
    end

    return counts.collect {|key,value| value > 1 ? key : nil }.compact.sort
  end
end # class Array


class PokerHand
  # I hate shoving the Rank and Card classes in here but its neccessary
  # to keep the program in one file
  
  class Rank
    include Comparable
    attr_accessor :value  
      
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
    
    def initialize v
      @value = v
    end

    def to_s
      case @value
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
    
    def <=> other
      @value <=> other.value
    end
  end   # class Rank

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
  
  
  include Comparable
  attr_reader :cards, :values_hash
  
  def initialize cards
    @cards = []
    @values_hash = Hash.new(0)
    
    begin
      if cards.class == String
        cards = cards.split
      elsif cards.class != Array
        # Input is neither a Sting or Array - throw exception
        raise
      end
    
      cards.each {|c| @cards << Card.new(c)}
      
      @cards.each {|c| @values_hash[c.value] += 1}
    rescue
      raise "Unable to process cards input. Please check the documentation for acceptable input formats"
    end
  end
  
  def rank
    @rank ||= self.determine_rank
  end
  
  # Returns an array of all the values in the hand. Does not
  # sort the values before returning them so Array#sort should
  # be called on the return value if sorting is desired.
  def values
    @cards.collect {|c| c.value}
  end
  
  # Flush: All cards of the same suit.
  def flush?
    @cards.collect {|c| c.suit}.uniq.size == 1
  end
  
  # Straight: All cards are consecutive values.
  def straight?
    straight = true   # innocent until proven guilty
    c_values = self.values.sort
    i = c_values.first
    c_values.each do |v|
      straight &&= (v == i)
      i += 1
    end
    return straight
  end

  # Royal Flush: Ten, Jack, Queen, King, Ace, in same suit.  
  def royal_flush?
    self.flush? and self.values.sort == [10,11,12,13,14]
  end
    
  # Straight Flush: All cards are consecutive values of same suit.
  def straight_flush?    
    self.flush? and self.straight?
  end
  
  # Full House: Three of a kind and a pair.
  def full_house?
    @values_hash.has_value?(3) and @values_hash.has_value?(2)
  end
  
  # Three of a Kind: Three cards of the same value.
  def three_of_a_kind?
    @values_hash.has_value?(3) and not full_house?
  end    
  
  # Four of a Kind: Four cards of the same value.  
  def four_of_a_kind?
    @values_hash.has_value?(4)
  end
  
  # Two Pair: Two different pairs.
  def two_pair?
    @values_hash.select {|k, v| v == 2}.size == 2   # check if two seperate values have two occurances
  end
  
  # One Pair: Two cards of the same value.
  def one_pair?
    @values_hash.select {|k, v| v == 2}.size == 1
  end

  def <=> hand2
    if self.rank != hand2.rank
      self.rank <=> hand2.rank
    else  # we have a tie... do a tie breaker
      case self.rank.value    # both hands have the same rank
      when 0, 4, 5, 8  # highest card, straight, flush, straight flush
        # check who has the highest card, if same move to the next card, etc
        self.values.sort.reverse <=> hand2.values.sort.reverse
      when 1  # two people with one pair
        # check which pair is higher, if the pairs are the same then remove the pairs and check
        # for highest card
        hand1_pair = @values_hash.index(2)  # get key(card value) of the duplicate pair
        hand2_pair = hand2.values_hash.index(2)
        if hand1_pair == hand2_pair
          return self.values.singles.reverse <=> hand2.values.singles.reverse
        else
          return hand1_pair <=> hand2_pair
        end
      when 2  # two people with two pairs
        # check who has the higher pair, if the pairs are the same
        # then remove the pairs and check for highest card
        hand1_pairs = self.values.duplicates.reverse
        hand2_pairs = hand2.values.duplicates.reverse
        if hand1_pairs == hand2_pairs
          return self.values.singles <=> hand2.values.singles   # there will be only one card remaining
        else
          return hand1_pairs <=> hand2_pairs
        end
      when 3, 6  # three_of_a_kind, full house
        @values_hash.index(3) <=> hand2.values_hash.index(3)
      when 7  # four of a kind
        @values_hash.index(4) <=> hand2.values_hash.index(4)
      when 9  # royal flush
        return 0  # royal flushes always tie
      end
    end
  end
  
  def to_s
    @cards.inject("") {|str, c| str << "#{c.to_s} "}.rstrip
  end
  
  protected
  
  def determine_rank
    if royal_flush?
      r = Rank::ROYAL_FLUSH
    elsif straight_flush?
      r = Rank::STRAIGHT_FLUSH
    elsif four_of_a_kind?
      r = Rank::FOUR_OF_A_KIND
    elsif full_house?
      r = Rank::FULL_HOUSE
    elsif flush?
      r = Rank::FLUSH
    elsif straight?
      r = Rank::STRAIGHT
    elsif three_of_a_kind?
      r = Rank::THREE_OF_A_KIND
    elsif two_pair?
      r = Rank::TWO_PAIR
    elsif one_pair?
      r = Rank::PAIR
    else
      r = Rank::HIGH_CARD
    end
    return Rank.new(r)
  end
end # class PokerHand