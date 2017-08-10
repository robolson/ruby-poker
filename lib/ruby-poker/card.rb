module RubyPoker
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
      'L' => 0, # this is a low ace
      '2' => 1,
      '3' => 2,
      '4' => 3,
      '5' => 4,
      '6' => 5,
      '7' => 6,
      '8' => 7,
      '9' => 8,
      'T' => 9,
      'J' => 10,
      'Q' => 11,
      'K' => 12,
      'A' => 13
    }

    def Card.face_value(face)
      FACE_VALUES[face.upcase]
    end

    private

    def build_from_value(given_value)
      @suit = given_value / 13
      @face = given_value % 13
    end

    def build_from_face_suit(face, suit)
      suit.downcase!
      @face = Card::face_value(face)
      @suit = SUIT_LOOKUP[suit]
      raise ArgumentError, "Invalid card: \"#{face}#{suit}\"" unless @face and @suit
    end

    def build_from_face_suit_values(face_int, suit_int)
      @face = face_int
      @suit = suit_int
    end

    def build_from_string(card)
      build_from_face_suit(card[0, 1], card[1, 1])
    end

    # Constructs this card object from another card object
    def build_from_card(card)
      @suit = card.suit
      @face = card.face
    end

    public

    def initialize(*args)
      if (args.size == 1)
        arg = args.first
        if (arg.respond_to?(:to_card))
          build_from_card(arg)
        elsif (arg.respond_to?(:to_str))
          build_from_string(arg)
        elsif (arg.respond_to?(:to_int))
          build_from_value(arg)
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

    attr_reader :suit, :face
    include Comparable

    def value
      (@suit * 13) + @face
    end

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
      value == card2.value
    end

    alias :eql? :==

    # Compute a hash-code for this Card. Two Cards with the same
    # content will have the same hash code (and will compare using eql?).
    def hash
      value.hash
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
      natural_face = @face == 13 ? 1 : @face+1 # flip Ace from 13 to 1 and
      # increment everything else by 1
      natural_face + @suit * 13
    end
  end
end
