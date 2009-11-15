class Seat
  attr_accessor :player, :chips, :number

  def initialize(chips = 1000)
    @player = nil
    @number = nil
    @chips = chips
  end
end
