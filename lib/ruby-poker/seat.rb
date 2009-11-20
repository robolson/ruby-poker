class Seat
  attr_accessor :player, :chips
  attr_reader :number

  def initialize(opts = {:number => nil, :player => nil, :chips => 0})
    @number = opts[:number]
    @player = opts[:player]
    @chips = opts[:chips]
  end
end
