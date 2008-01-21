class Deck
  def shuffle
    deck_size = @cards.size
    (deck_size * 2).times do
      pos1, pos2 = rand(deck_size), rand(deck_size)
      @cards[pos1], @cards[pos2] = @cards[pos2], @cards[pos1]
    end
  end

  def initialize
    @cards = []
    Card::SUITS.each_byte do |suit|
      # careful not to double include the aces...
      Card::FACES[1..-1].each_byte do |face|
        @cards.push(Card.new(face.chr, suit.chr))
      end
    end
    shuffle()
  end

  def deal
    @cards.pop
  end

  def empty?
    @cards.empty?
  end
end