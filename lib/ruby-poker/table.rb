require 'rubygems'
require 'ruby-debug'

class Table
  attr_accessor :seats, :button, :pot

  def initialize(seats=10)
    @seats = []
    (1..seats).each {
      @seats << Seat.new
    }
    @button = nil
    @small_blind = 10
    @big_blind = 20
    @pot = 0
    @deck = Deck.new
  end

  def sit(player, seat, buyin)
    unless @seats[seat].player
      @seats[seat].player = player
      @seats[seat].chips = buyin
      @button = seat unless @button
    end
  end

  def deal
    raise "No players" if seated_players.length < 1
    raise "Less than 2 players" if seated_players.length < 2


    # XXX: make sure that all players have $

    # XXX: move button

    # XXX: take blinds
    @deck.shuffle

    seated = seated_players
    @seats[utg].player.hand = @deck.deal
  end

  def button_move
    seated = seated_players
    bi = seated.index(@button)
    if bi == seated.last
      @button = seated.first
    else
      @button = seated[bi+1]
    end
  end

  def action_order_preflop
    seated = seated_positions
    order = []
    first = seated[seated.index(utg)..-1]
    last = seated[0..seated.index(utg)-1]
    order += first if first
    order += last if last
    order
  end

  def action_order_postflop
    seated = seated_positions
    order = []
    first = seated[seated.index(sb)..-1]
    last = seated[0..seated.index(sb)-1]
    order += first if first
    order += last if last
    order
  end

  def utg
    seated = seated_positions
    bbi = seated.index(bb)
    if bbi == seated.last
      return seated.first
    else
      return seated[bbi+1]
    end
  end

  def bb
    seated = seated_positions
    sbi = seated.index(sb)
    if sbi == seated.last
      return seated.first
    else
      return seated[sbi+1]
    end
  end

  def sb
    seated = seated_positions
    bi = seated.index(@button)
    if bi == seated.last
      return seated.first
    else
      return seated[bi+1]
    end
  end

  private

  def seated_positions
    positions = []
    (0..@seats.length-1).each { |x|
      positions << x if @seats[x].player
    }
    positions
  end

  def seated_players
    players = []
    (0..@seats.length-1).each { |x|
      players << @seats[x].player if @seats[x].player
    }
    players
  end
end
