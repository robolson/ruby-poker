class Seat
  attr_accessor :player, :chips

  def initialize(chips = 1000)
    @player = nil
    @chips = chips
  end
end
