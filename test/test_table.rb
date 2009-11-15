require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestTable < Test::Unit::TestCase
  context "Basic stuff" do
    setup do
      @table = Table.new
    end

    should "a table should have 10 seats by default" do
      assert_equal(@table.seats.length, 10)
    end

    should "all seats at a new table should be empty" do
      @table.seats.each { |seat|
        assert_equal(seat.player, nil)
      }
    end

    should "players should be able to sit down" do
      player = Player.new(5000)
      @table.sit(player, 4, 1000)
    end

    should "players shouldn't be able to sit down in an occupied seat" do
      player1 = Player.new(5000)
      @table.sit(player1, 4, 1000)

      player2 = Player.new(5000)
      @table.sit(player2, 4, 1000)

      assert_equal(@table.seats[4].player, player1)
    end
  end

  context "Order stuff" do
    setup do
      @table = Table.new
      @table.sit(Player.new(5000), 1, 1000)
      @table.sit(Player.new(5000), 3, 1000)
      @table.sit(Player.new(5000), 5, 1000)
      @table.sit(Player.new(5000), 7, 1000)
      @table.sit(Player.new(5000), 9, 1000)
    end

    should "get correct button position" do
      assert_equal(1, @table.button)
    end

    should "get player in sb" do
      assert_equal(3, @table.sb)
    end

    should "get player in bb" do
      assert_equal(5, @table.bb)
    end

    should "get utg player" do
      assert_equal(7, @table.utg)
    end

    should "get correct deal order preflop" do
      assert_equal([7, 9, 1, 3, 5], @table.action_order_preflop)
    end

    should "get correct action order postflop" do
      assert_equal([3, 5, 7, 9, 1], @table.action_order_postflop)
    end
  end

  context "Deal stuff" do
    setup do
      @table = Table.new(10, 1)
      @table.sit(Player.new(5000), 1, 1000)
      @table.sit(Player.new(5000), 3, 1000)
      @table.sit(Player.new(5000), 5, 1000)
      @table.sit(Player.new(5000), 7, 1000)
      @table.sit(Player.new(5000), 9, 1000)
    end

    should "deal 2 hole cards to each player" do
      @table.deal_holes
      @table.seats.each { |seat|
        if seat.player
          assert_equal(2, seat.player.hand.to_a.length)
        end
      }
    end

    should "deal flop" do
      @table.deal_holes
      @table.deal_flop
      assert_equal(3, @table.community.to_a.length)
    end

    should "deal turn" do
      @table.deal_holes
      @table.deal_flop
      @table.deal_turn
      assert_equal(4, @table.community.to_a.length)
    end

    should "deal river" do
      @table.deal_holes
      @table.deal_flop
      @table.deal_turn
      @table.deal_river
      assert_equal(5, @table.community.to_a.length)
    end

    should "determine winner" do
      @table.deal_holes
      @table.deal_flop
      @table.deal_turn
      @table.deal_river
      winner, best_hand = @table.winner
      assert_equal(winner, 1)
    end
  end

  context "Outcomes" do
    should "Handle Ties" do
      @table = Table.new(10, 2)
      @table.sit(Player.new(5000), 1, 1000)
      @table.sit(Player.new(5000), 3, 1000)
      @table.sit(Player.new(5000), 5, 1000)
      @table.sit(Player.new(5000), 7, 1000)
      @table.sit(Player.new(5000), 9, 1000)
      @table.deal_holes
      @table.deal_flop
      @table.deal_turn
      @table.deal_river
      winner, best_hand = @table.winner
    end

  end
end
