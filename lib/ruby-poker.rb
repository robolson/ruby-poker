require 'card.rb'

class PokerHand
  include Comparable
  attr_reader :hand
  
  # Returns a new PokerHand object. Accepts the cards represented
  # in a string or an array
  #
  #     PokerHand.new("3d 5c 8h Ks")   # => #<PokerHand:0x5c673c ...
  #     PokerHand.new(["3d", "5c", "8h", "Ks"])  # => #<PokerHand:0x5c2d6c ...
  def initialize(cards = [])
    if cards.is_a? Array
      @hand = cards.map do |card|
        if card.is_a? Card
          card
        else
          Card.new(card.to_s)
        end
      end
    elsif cards.respond_to?(:to_str)
      @hand = cards.scan(/\S{2,3}/).map { |str| Card.new(str) }
    else
      @hand = cards
    end
  end

  # Returns a new PokerHand object with the cards sorted by suit
  # The suit order is spades, hearts, diamonds, clubs
  #
  #     PokerHand.new("3d 5c 8h Ks").by_suit.just_cards   # => "Ks 8h 3d 5c"
  def by_suit
    PokerHand.new(@hand.sort_by { |c| [c.suit, c.face] }.reverse)
  end

  # Returns a new PokerHand object with the cards sorted by value
  # with the highest value first.
  #
  #     PokerHand.new("3d 5c 8h Ks").by_face.just_cards   # => "Ks 8h 5c 3d"
  def by_face
    PokerHand.new(@hand.sort_by { |c| [c.face, c.suit] }.reverse)
  end
  
  # Returns string representation of the hand without the rank
  #
  #     PokerHand.new(["3c", "Kh"]).just_cards     # => "3c Kh"
  def just_cards
    @hand.join(" ")
  end
  alias :cards :just_cards
  
  # Returns an array of the card values in the hand.
  # The values returned are 1 less than the value on the card.
  # For example: 2's will be shown as 1.
  #
  #     PokerHand.new(["3c", "Kh"]).face_values     # => [2, 12]
  def face_values
    @hand.map { |c| c.face }
  end

  def =~ (re)
    re.match(just_cards)
  end

  def royal_flush?
    if (md = (by_suit =~ /A(.) K\1 Q\1 J\1 T\1/))
      [[10], arrange_hand(md)]
    else
      false
    end
  end

  def straight_flush?
    if (md = (/.(.)(.)(?: 1.\2){4}/.match(delta_transform(true))))
      high_card = Card::face_value(md[1])
      arranged_hand = fix_low_ace_display(md[0] + ' ' +
          md.pre_match + ' ' + md.post_match)
      [[9, high_card], arranged_hand]
    else
      false
    end
  end

  def four_of_a_kind?
    if (md = (by_face =~ /(.). \1. \1. \1./))
      # get kicker
      (md.pre_match + md.post_match).match(/(\S)/)
      [
        [8, Card::face_value(md[1]), Card::face_value($1)],
        arrange_hand(md)
      ]
    else
      false
    end
  end

  def full_house?
    if (md = (by_face =~ /(.). \1. \1. (.*)(.). \3./))
      arranged_hand = arrange_hand(md[0] + ' ' +
          md.pre_match + ' ' + md[2] + ' ' + md.post_match)
      [
        [7, Card::face_value(md[1]), Card::face_value(md[3])],
        arranged_hand
      ]
    elsif (md = (by_face =~ /((.). \2.) (.*)((.). \5. \5.)/))
      arranged_hand = arrange_hand(md[4] + ' '  + md[1] + ' ' +
          md.pre_match + ' ' + md[3] + ' ' + md.post_match)
      [
        [7, Card::face_value(md[5]), Card::face_value(md[2])],
        arranged_hand
      ]
    else
      false
    end
  end

  def flush?
    if (md = (by_suit =~ /(.)(.) (.)\2 (.)\2 (.)\2 (.)\2/))
      [
        [
          6,
          Card::face_value(md[1]),
          *(md[3..6].map { |f| Card::face_value(f) })
        ],
        arrange_hand(md)
      ]
    else
      false
    end
  end

  def straight?
    result = false
    if hand.size >= 5
      transform = delta_transform
      # note we can have more than one delta 0 that we
      # need to shuffle to the back of the hand
      i = 0
      until transform.match(/^\S{3}( [1-9x]\S\S)+( 0\S\S)*$/) or i >= hand.size  do
        # only do this once per card in the hand to avoid entering an
        # infinite loop if all of the cards in the hand are the same
        transform.gsub!(/(\s0\S\S)(.*)/, "\\2\\1")    # moves the front card to the back of the string
        i += 1
      end
      if (md = (/.(.). 1.. 1.. 1.. 1../.match(transform)))
        high_card = Card::face_value(md[1])
        arranged_hand = fix_low_ace_display(md[0] + ' ' + md.pre_match + ' ' + md.post_match)
        result = [[5, high_card], arranged_hand]
      end
    end
  end

  def three_of_a_kind?
    if (md = (by_face =~ /(.). \1. \1./))
      # get kicker
      arranged_hand = arrange_hand(md)
      arranged_hand.match(/(?:\S\S ){3}(\S)\S (\S)/)
      [
        [
          4,
          Card::face_value(md[1]),
          Card::face_value($1),
          Card::face_value($2)
        ],
        arranged_hand
      ]
    else
      false
    end
  end

  def two_pair?
    if (md = (by_face =~ /(.). \1.(.*) (.). \3./))
      # get kicker
      arranged_hand = arrange_hand(md[0] + ' ' +
          md.pre_match + ' ' + md[2] + ' ' + md.post_match)
      arranged_hand.match(/(?:\S\S ){4}(\S)/)
      [
        [
          3,
          Card::face_value(md[1]),
          Card::face_value(md[3]),
          Card::face_value($1)
        ],
        arranged_hand
      ]
    else
      false
    end
  end

  def pair?
    if (md = (by_face =~ /(.). \1./))
      # get kicker
      arranged_hand = arrange_hand(md)
      arranged_hand.match(/(?:\S\S ){2}(\S)\S\s+(\S)\S\s+(\S)/)
      [
        [
          2,
          Card::face_value(md[1]),
          Card::face_value($1),
          Card::face_value($2),
          Card::face_value($3)
        ],
        arranged_hand
      ]
    else
      false
    end
  end

  def highest_card?
    result = by_face
    [[1, *result.face_values[0..4]], result.hand.join(' ')]
  end

  OPS = [
    ['Royal Flush',     :royal_flush? ],
    ['Straight Flush',  :straight_flush? ],
    ['Four of a kind',  :four_of_a_kind? ],
    ['Full house',      :full_house? ],
    ['Flush',           :flush? ],
    ['Straight',        :straight? ],
    ['Three of a kind', :three_of_a_kind?],
    ['Two pair',        :two_pair? ],
    ['Pair',            :pair? ],
    ['Highest Card',    :highest_card? ],
  ]

  # Returns the verbose hand rating
  #
  #     PokerHand.new("4s 5h 6c 7d 8s").hand_rating     # => "Straight"
  def hand_rating
    OPS.map { |op|
      (method(op[1]).call()) ? op[0] : false
    }.find { |v| v }
  end
  
  alias :rank :hand_rating
  
  def score
    OPS.map { |op|
      method(op[1]).call()
    }.find([0]) { |score| score }
  end

  # Returns a string of the hand arranged based on its rank. Usually this will be the
  # same as `by_face` but there are some cases where it makes a difference.
  #
  #     ph = PokerHand.new("AS 3S 5S 2S 4S")
  #     ph.sort_using_rank        # => "5s 4s 3s 2s As"
  #     ph.by_face.just_cards       # => "As 5s 4s 3s 2s"   
  def sort_using_rank
    score[1]
  end
  
  # Returns string with a listing of the cards in the hand followed by the hand's rank.
  #
  #     h = PokerHand.new("8c 8s")
  #     h.to_s                      # => "8c 8s (Pair)"
  def to_s
    just_cards + " (" + hand_rating + ")"
  end
  
  # Returns an array of `Card` objects that make up the `PokerHand`.
  def to_a
    @hand
  end
  
  alias :to_ary :to_a
  
  def <=> other_hand
    self.score[0] <=> other_hand.score[0]
  end
  
  # Add a card to the hand
  # 
  #     hand = PokerHand.new("5d")
  #     hand << "6s"          # => Add a six of spades to the hand by passing a string
  #     hand << ["7h", "8d"]  # => Add multiple cards to the hand using an array
  def << new_cards
    if new_cards.is_a?(Card) || new_cards.is_a?(String)
      new_cards = [new_cards]
    end
    
    new_cards.each do |nc|
      @hand << Card.new(nc)
    end
  end
  
  # Remove a card from the hand.
  #
  #     hand = PokerHand.new("5d Jd")
  #     hand.delete("Jd")           # => #<Card:0x5d0674 @value=23, @face=10, @suit=1>
  #     hand.just_cards             # => "5d"
  def delete card
    @hand.delete(Card.new(card))
  end
  
  RESOLVING_METHODS = ['size', '+', '-']
  RESOLVING_METHODS.each do |method|
    class_eval %{
      def #{method}(*args, &block)
        @hand.#{method}(*args, &block)
      end
    }
  end
  
  # protected
  
  def arrange_hand(md)
      hand = if (md.respond_to?(:to_str))
        md
      else
        md[0] + ' ' + md.pre_match + md.post_match
      end
      hand.gsub!(/\s+/, ' ')
      hand.gsub(/\s+$/,'')
  end
  
  def delta_transform(use_suit = false)
    aces = @hand.select { |c| c.face == Card::face_value('A') }
    aces.map! { |c| Card.new(1,c.suit) }

    base = if (use_suit)
      (@hand + aces).sort_by { |c| [c.suit, c.face] }.reverse
    else
      (@hand + aces).sort_by { |c| [c.face, c.suit] }.reverse
    end

    result = base.inject(['',nil]) do |(delta_hand, prev_card), card|
      if (prev_card)
        delta = prev_card - card.face
      else
        delta = 0
      end
      # does not really matter for my needs
      delta = 'x' if (delta > 9 || delta < 0)
      delta_hand += delta.to_s + card.to_s + ' '
      [delta_hand, card.face]
    end

    # we just want the delta transform, not the last cards face too
    result[0].chop
  end

  def fix_low_ace_display(arranged_hand)
    # remove card deltas (this routine is only used for straights)
    arranged_hand.gsub!(/\S(\S\S)\s*/, "\\1 ")

    # Fix "low aces"
    arranged_hand.gsub!(/L(\S)/, "A\\1")

    # Remove duplicate aces (this will not work if you have
    # multiple decks or wild cards)
    arranged_hand.gsub!(/((A\S).*)\2/, "\\1")

    # cleanup white space
    arranged_hand.gsub!(/\s+/, ' ')
    # careful to use gsub as gsub! can return nil here
    arranged_hand.gsub(/\s+$/, '')
  end
  
end