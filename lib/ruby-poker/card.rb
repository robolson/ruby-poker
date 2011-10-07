class Card
  SUITS = "cdhs"
  FACES = "L23456789TJQKA"
  SUIT_LOOKUP = {
    'c' => 0,
    'd' => 1,
    'h' => 2,
    's' => 3
  }
  FACE_VALUES = {
    'L' =>  1,   # this is a magic low ace
    '2' =>  2,
    '3' =>  3,
    '4' =>  4,
    '5' =>  5,
    '6' =>  6,
    '7' =>  7,
    '8' =>  8,
    '9' =>  9,
    'T' => 10,
    'J' => 11,
    'Q' => 12,
    'K' => 13,
    'A' => 14
  }

  def Card.face_value(face)
    face.upcase!
    if face == 'L' || !FACE_VALUES.has_key?(face)
      nil
    else
      FACE_VALUES[face] - 1
    end
  end

  private

  def build_from_value(value)
    @value = value
    @suit  = value / FACES.size()
    @face  = (value % FACES.size())
  end

  def build_from_face_suit(face, suit)
    suit.downcase!
    @face  = Card::face_value(face)
    @suit  = SUIT_LOOKUP[suit]
    raise ArgumentError, "Invalid card: \"#{face}#{suit}\"" unless @face and @suit
    @value = (@suit * FACES.size()) + (@face - 1)
  end

  def build_from_face_suit_values(face, suit)
    build_from_value((face - 1) + (suit * FACES.size()))
  end

  def build_from_string(card)
    build_from_face_suit(card[0,1], card[1,1])
  end

  # Constructs this card object from another card object
  def build_from_card(card)
    @value = card.value
    @suit = card.suit
    @face = card.face
  end

  public

  def initialize(*args)
    if (args.size == 1)
      value = args.first
      if (value.respond_to?(:to_card))
        build_from_card(value)
      elsif (value.respond_to?(:to_str))
        build_from_string(value)
      elsif (value.respond_to?(:to_int))
        build_from_value(value)
      end
    elsif (args.size == 2)
      arg1, arg2 = args
      if (arg1.respond_to?(:to_str) &&
          arg2.respond_to?(:to_str))
        build_from_face_suit(arg1, arg2)
      elsif (arg1.respond_to?(:to_int) &&
             arg2.respond_to?(:to_int))
        build_from_face_suit_values(arg1, arg2)
      end
    end
  end

  attr_reader :suit, :face, :value
  include Comparable

  # Returns a string containing the representation of Card
  #
  # Card.new("7c").to_s                   # => "7c"
  def to_s
    FACES[@face].chr + SUITS[@suit].chr
  end

  # If to_card is called on a `Card` it should return itself
  def to_card
    self
  end

  # Compare the face value of this card with another card. Returns:
  # -1 if self is less than card2
  # 0 if self is the same face value of card2
  # 1 if self is greater than card2
  def <=> card2
    @face <=> card2.face
  end

  # Returns true if the cards are the same card. Meaning they
  # have the same suit and the same face value.
  def == card2
    @value == card2.value
  end
  alias :eql? :==

  # Compute a hash-code for this Card. Two Cards with the same
  # content will have the same hash code (and will compare using eql?).
  def hash
    @value.hash
  end

  # A card's natural value is the closer to it's intuitive value in a deck
  # in the range of 1 to 52. Aces are low with a value of 1. Uses the bridge
  # order of suits: clubs, diamonds, hearts, and spades. The formula used is:
  # If the suit is clubs, the natural value is the face value (remember
  # Aces are low). If the suit is diamonds, it is the clubs value plus 13.
  # If the suit is hearts, it is plus 26. If it is spades, it is plus 39.
  #
  #     Card.new("Ac").natural_value    # => 1
  #     Card.new("Kc").natural_value    # => 12
  #     Card.new("Ad").natural_value    # => 13
  def natural_value
    natural_face = @face == 13 ? 1 : @face+1  # flip Ace from 13 to 1 and
                                              # increment everything else by 1
    natural_face + @suit * 13
  end
end
