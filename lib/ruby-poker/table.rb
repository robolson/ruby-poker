require 'rubygems'
require 'ruby-debug'

class Table
  attr_accessor :seats, :button, :pot
  attr_accessor :flop, :turn, :river, :community

  def initialize(seats=10, seed=nil)
    @seats = []
    (0..seats-1).each { |x|
      @seats << Seat.new(:number => x)
    }
    @button = nil
    @small_blind = 10
    @big_blind = 20
    @pot = 0
    @deck = Deck.new(seed)
    @flop = nil
    @turn = nil
    @river = nil
    @seed = seed if seed
  end

  def sit(player, seat, buyin)
    unless @seats[seat].player
      @seats[seat].player = player
      @seats[seat].chips = buyin
      @button = seat unless @button
    end
  end

  def run_hand
    deal_holes
    deal_flop
    deal_turn
    deal_river
    seats, best_hand, hands = winners
    # XXX: handle pot
    # XXX: move button
    return seats, best_hand, hands
  end

  def deal_holes
    raise "No players" if seated_players.length < 1
    raise "Less than 2 players" if seated_players.length < 2

    # XXX: make sure that all players have $

    collect_blinds

    @deck.shuffle(@seed) if @seed
    @deck.shuffle() unless @seed

    @community = PokerHand.new

    action_order_preflop.each { |x|
      @seats[x].player.hand = PokerHand.new
      @seats[x].player.hand << @deck.deal
    }
    action_order_preflop.each { |x|
      @seats[x].player.hand << @deck.deal
    }
  end

  def deal_flop
    #@deck.burn(@deck.deal)
    @flop = PokerHand.new([@deck.deal, @deck.deal, @deck.deal])
    @community << @flop.to_a
  end

  def deal_turn
    #@deck.burn(@deck.deal)
    @turn = PokerHand.new(@deck.deal)
    @community << @turn.to_a
  end

  def deal_river
    #@deck.burn(@deck.deal)
    @river = PokerHand.new(@deck.deal)
    @community << @river.to_a
  end

  def dump_hands
    puts
    @seats.each { |s|
      msg = "%02d: " % s.number
      unless s.player
        msg += "empty"
      else
        if s.player.hand
          holes = s.player.hand
          hand = PokerHand.new(@community.to_a + holes.to_a)
          rank = hand.rank_full
          msg += "#{holes} - #{rank} (#{hand.just_cards})"
        else
          msg += "no cards"
        end
      end
      puts msg
    }
  end

  def winners
    best_hand = nil
    winners = []
    hands = []
    #puts
    @seats.each { |seat|
      if seat.player
        hand = PokerHand.new(seat.player.hand.to_a)
        hand << @community.to_a
        hands << hand
        unless best_hand
          best_hand = hand
          winners << seat.number
          #puts "seat #{seat.number} (#{seat.player.hand.just_cards}): #{hand.five_card_s}"
        else
          if hand > best_hand
            #puts "seat #{seat.number} (#{seat.player.hand.just_cards}): better hand: #{hand.five_card_s}"
            best_hand = hand
            winners.clear
            winners << seat.number
          elsif hand == best_hand
            # XXX: finish this
            #puts "XXX Tie: seat #{seat.number} (#{seat.player.hand.just_cards}): tie hand: #{hand.five_card_s}"
            winners << seat.number
          else
            #puts "seat #{seat.number} (#{seat.player.hand.just_cards}): worse hand: #{hand.five_card_s}"
          end
        end
      end
    }
    #puts "Winners: seats #{winners.join(',')} with #{best_hand.five_card_s}"
    return [winners, best_hand, hands]
  end

  def collect_blinds
    @seats[sb].chips -= @small_blind
    @seats[bb].chips -= @big_blind
    @pot += @small_blind
    @pot += @big_blind
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
