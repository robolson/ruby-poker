require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestPokerHand < Test::Unit::TestCase
  context "Hole cards only" do
  end

  context "Flop (with As Ks in the hole)" do
    setup do
      @ace_king_suited = PokerHand.new("As Ks")
    end

    should "Get odds of a pair" do
      pair_either = 0.30 # get from poker odds book
      assert_equal(pair_either, @ace_king_suited.pair_odds)
    end
  end
end
