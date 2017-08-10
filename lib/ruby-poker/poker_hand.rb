module RubyPoker
  class PokerHand
    include Comparable
    include Enumerable
    attr_reader :hand

    @@allow_duplicates = true # true by default
    def self.allow_duplicates;
      @@allow_duplicates;
    end

    def self.allow_duplicates=(v)
      ; @@allow_duplicates = v;
    end

    # Returns a new PokerHand object. Accepts the cards represented
    # in a string or an array
    #
    #     PokerHand.new("3d 5c 8h Ks")   # => #<PokerHand:0x5c673c ...
    #     PokerHand.new(["3d", "5c", "8h", "Ks"])  # => #<PokerHand:0x5c2d6c ...
    def initialize(cards = [])
      @hand = case cards
                when Array
                  cards.map do |card|
                    if card.is_a? Card
                      card
                    else
                      Card.new(card.to_s)
                    end
                  end
                when String
                  cards.scan(/\S{2}/).map { |str| Card.new(str) }
                else
                  cards
              end

      check_for_duplicates unless allow_duplicates
    end

    # Returns a new PokerHand object with the cards sorted by suit
    # The suit order is spades, hearts, diamonds, clubs
    #
    #     PokerHand.new("3d 5c 8h Ks").by_suit.just_cards   # => "Ks 8h 3d 5c"
    def by_suit
      PokerHand.new(@hand.sort_by { |c| [c.suit, c.face] }.reverse)
    end

    # Returns a new PokerHand object with the cards sorted by face value
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

    # The =~ method does a regular expression match on the cards in this hand.
    # This can be useful for many purposes. A common use is the check if a card
    # exists in a hand.
    #
    #     PokerHand.new("3d 4d 5d") =~ /8h/           # => nil
    #     PokerHand.new("3d 4d 5d") =~ /4d/           # => #<MatchData:0x615e18>
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
        result = [8, Card::face_value(md[1])]
        result << Card::face_value($1) if (md.pre_match + md.post_match).match(/(\S)/)
        return [result, arrange_hand(md)]
      end
      false
    end

    def full_house?
      if (md = (by_face =~ /(.). \1. \1. (.*)(.). \3./))
        arranged_hand = rearrange_full_house(by_face.cards)
        [
          [7, Card::face_value(md[1]), Card::face_value(md[3])],
          arranged_hand
        ]
      elsif (md = (by_face =~ /((.). \2.) (.*)((.). \5. \5.)/))
        arranged_hand = rearrange_full_house(by_face.cards)
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
      if hand.size >= 5
        transform = delta_transform
        # note we can have more than one delta 0 that we
        # need to shuffle to the back of the hand
        i = 0
        until transform.match(/^\S{3}( [1-9x]\S\S)+( 0\S\S)*$/) or i >= hand.size do
          # only do this once per card in the hand to avoid entering an
          # infinite loop if all of the cards in the hand are the same
          transform.gsub!(/(\s0\S\S)(.*)/, "\\2\\1") # moves the front card to the back of the string
          i += 1
        end
        if (md = (/.(.). 1.. 1.. 1.. 1../.match(transform)))
          high_card = Card::face_value(md[1])
          arranged_hand = fix_low_ace_display(md[0] + ' ' + md.pre_match + ' ' + md.post_match)
          return [[5, high_card], arranged_hand]
        end
      end
      false
    end

    def three_of_a_kind?
      if (md = (by_face =~ /(.). \1. \1./))
        # get kicker
        arranged_hand = arrange_hand(md)
        matches = arranged_hand.match(/(?:\S\S ){2}(\S\S)/)
        if matches
          result = [4, Card::face_value(md[1])]
          matches = arranged_hand.match(/(?:\S\S ){3}(\S)/)
          result << Card::face_value($1) if matches
          matches = arranged_hand.match(/(?:\S\S ){3}(\S)\S (\S)/)
          result << Card::face_value($2) if matches
          return [result, arranged_hand]
        end
      end
      false
    end

    def two_pair?
      # \1 is the face value of the first pair
      # \2 is the card in between the first pair and the second pair
      # \3 is the face value of the second pair
      if (md = (by_face =~ /(.). \1.(.*?) (.). \3./))
        # to get the kicker this does the following
        # md[0] is the regex matched above which includes the first pair and
        # the second pair but also some cards in the middle so we sub them out
        # then we add on the cards that came before the first pair, the cards
        # that were in-between, and the cards that came after.
        arranged_hand = arrange_hand(md[0].sub(md[2], '') + ' ' +
                                       md.pre_match + ' ' + md[2] + ' ' + md.post_match)
        matches = arranged_hand.match(/(?:\S\S ){3}(\S\S)/)
        if matches
          result = []
          result << 3
          result << Card::face_value(md[1]) # face value of the first pair
          result << Card::face_value(md[3]) # face value of the second pair
          matches = arranged_hand.match(/(?:\S\S ){4}(\S)/)
          result << Card::face_value($1) if matches # face value of the kicker
          return [result, arranged_hand]
        end
      end
      false
    end

    def pair?
      if (md = (by_face =~ /(.). \1./))
        arranged_hand_str = arrange_hand(md)
        arranged_hand = PokerHand.new(arranged_hand_str)

        if arranged_hand.hand[0].face == arranged_hand.hand[1].face &&
          arranged_hand.hand[0].suit != arranged_hand.hand[1].suit
          result = [2, arranged_hand.hand[0].face]
          result << arranged_hand.hand[2].face if arranged_hand.size > 2
          result << arranged_hand.hand[3].face if arranged_hand.size > 3
          result << arranged_hand.hand[4].face if arranged_hand.size > 4

          return [result, arranged_hand_str]
        end
      else
        false
      end
    end

    def highest_card?
      if size > 0
        result = by_face
        [[1, *result.face_values[0..result.face_values.length]], result.hand.join(' ')]
      else
        false
      end
    end

    def empty_hand?
      if size == 0
        [[0]]
      end
    end

    OPS = [
      ['Royal Flush', :royal_flush?],
      ['Straight Flush', :straight_flush?],
      ['Four of a kind', :four_of_a_kind?],
      ['Full house', :full_house?],
      ['Flush', :flush?],
      ['Straight', :straight?],
      ['Three of a kind', :three_of_a_kind?],
      ['Two pair', :two_pair?],
      ['Pair', :pair?],
      ['Highest Card', :highest_card?],
      ['Empty Hand', :empty_hand?],
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
      # OPS.map returns an array containing the result of calling each OPS method against
      # the poker hand. The truthy cell closest to the front of the array represents
      # the highest ranking.
      OPS.map { |op|
        method(op[1]).call()
      }.find { |score| score }
    end

    # Returns a string of the hand arranged based on its rank. Usually this will be the
    # same as by_face but there are some cases where it makes a difference.
    #
    #     ph = PokerHand.new("As 3s 5s 2s 4s")
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
      self.score[0].compact <=> other_hand.score[0].compact
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
        unless allow_duplicates
          raise "A card with the value #{nc} already exists in this hand. Set PokerHand.allow_duplicates to true if you want to be able to add a card more than once." if self =~ /#{nc}/
        end

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

    # Same concept as Array#uniq
    def uniq
      PokerHand.new(@hand.uniq)
    end

    # Resolving methods are just passed directly down to the @hand array
    RESOLVING_METHODS = [:each, :size, :-]
    RESOLVING_METHODS.each do |method|
      class_eval %{
      def #{method}(*args, &block)
        @hand.#{method}(*args, &block)
      end
    }
    end

    def allow_duplicates
      @@allow_duplicates
    end

    # Checks whether the hand matches usual expressions like AA, AK, AJ+, 66+, AQs, AQo...
    #
    # Valid expressions:
    # * "AJ": Matches exact faces (in this case an Ace and a Jack), suited or not
    # * "AJs": Same but suited only
    # * "AJo": Same but offsuit only
    # * "AJ+": Matches an Ace with any card >= Jack, suited or not
    # * "AJs+": Same but suited only
    # * "AJo+": Same but offsuit only
    # * "JJ+": Matches any pair >= "JJ".
    # * "8T+": Matches connectors (in this case with 1 gap : 8T, 9J, TQ, JK, QA)
    # * "8Ts+": Same but suited only
    # * "8To+": Same but offsuit only
    #
    # The order of the cards in the expression is important (8T+ is not the same as T8+), but the order of the cards in the hand is not ("AK" will match "Ad Kc" and "Kc Ad").
    #
    # The expression can be an array of expressions. In this case the method returns true if any expression matches.
    #
    # This method only works on hands with 2 cards.
    #
    #     PokerHand.new('Ah Ad').match? 'AA' # => true
    #     PokerHand.new('Ah Kd').match? 'AQ+' # => true
    #     PokerHand.new('Jc Qc').match? '89s+' # => true
    #     PokerHand.new('Ah Jd').match? %w( 22+ A6s+ AJ+ ) # => true
    #     PokerHand.new('Ah Td').match? %w( 22+ A6s+ AJ+ ) # => false
    #
    def match? expression
      raise "Hands with #{@hand.size} cards is not supported" unless @hand.size == 2

      if expression.is_a? Array
        return expression.any? { |e| match?(e) }
      end

      faces = @hand.map { |card| card.face }.sort.reverse
      suited = @hand.map { |card| card.suit }.uniq.size == 1
      if expression =~ /^(.)(.)(s|o|)(\+|)$/
        face1 = Card.face_value($1)
        face2 = Card.face_value($2)
        raise ArgumentError, "Invalid expression: #{expression.inspect}" unless face1 and face2
        suit_match = $3
        plus = ($4 != "")

        if plus
          if face1 == face2
            face_match = (faces.first == faces.last and faces.first >= face1)
          elsif face1 > face2
            face_match = (faces.first == face1 and faces.last >= face2)
          else
            face_match = ((faces.first - faces.last) == (face2 - face1) and faces.last >= face1)
          end
        else
          expression_faces = [face1, face2].sort.reverse
          face_match = (expression_faces == faces)
        end
        case suit_match
          when ''
            face_match
          when 's'
            face_match and suited
          when 'o'
            face_match and !suited
        end
      else
        raise ArgumentError, "Invalid expression: #{expression.inspect}"
      end
    end

    def +(other)
      cards = @hand.map { |card| Card.new(card) }
      case other
        when String
          cards << Card.new(other)
        when Card
          cards << other
        when PokerHand
          cards += other.hand
        else
          raise ArgumentError, "Invalid argument: #{other.inspect}"
      end
      PokerHand.new(cards)
    end

    private

    def check_for_duplicates
      if @hand.size != @hand.uniq.size && !allow_duplicates
        raise "Attempting to create a hand that contains duplicate cards. Set PokerHand.allow_duplicates to true if you do not want to ignore this error."
      end
    end

    # if md is a string, arrange_hand will remove extra white space
    # if md is a MatchData, arrange_hand returns the matched segment
    # followed by the pre_match and the post_match
    def arrange_hand(md)
      hand = if md.respond_to?(:to_str)
               md
             else
               md[0] + ' ' + md.pre_match + md.post_match
             end
      hand.strip.squeeze(" ") # remove extra whitespace
    end

    # delta transform returns a string representation of the cards where the
    # delta between card values is in the string. This is necessary so a regexp
    # can then match a straight and/or straight flush
    #
    # Examples
    #
    #   PokerHand.new("As Qc Jh Ts 9d 8h")
    #   # => '0As 2Qc 1Jh 1Ts 19d 18h'
    #
    #   PokerHand.new("Ah Qd Td 5d 4d")
    #   # => '0Ah 2Qd 2Td 55d 14d'
    #
    def delta_transform(use_suit = false)
      # In order to check for both ace high and ace low straights we create low
      # ace duplicates of all of the high aces.
      aces = @hand.select { |c| c.face == Card::face_value('A') }
      aces.map! { |c| Card.new(0, c.suit) } # hack to give the appearance of a low ace

      base = if (use_suit)
               (@hand + aces).sort_by { |c| [c.suit, c.face] }.reverse
             else
               (@hand + aces).sort_by { |c| [c.face, c.suit] }.reverse
             end

      # Insert delta in front of each card
      result = base.inject(['', nil]) do |(delta_hand, prev_card), card|
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

    def rearrange_full_house(cards)
      card_array = cards.split.uniq
      card_hash = Hash[card_array.collect { |c| [c[0], card_array.count { |n| n[0] == c[0] }] }]
      arranged_hand = card_array.select { |c| c if c[0] == card_hash.key(3) }
      arranged_hand += card_array.select { |c| c if c[0] == card_hash.key(2) }
      (arranged_hand + (card_array - arranged_hand)).join(" ")
    end

  end
end
