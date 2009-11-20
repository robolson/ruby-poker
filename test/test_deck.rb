require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestDeck < Test::Unit::TestCase
  context "Seeded deck" do
    setup do
    end

    should "Get the same order every time" do
      table = Table.new(10, 89)
      # 7's full of 4's
      table.sit(Player.new(5000), 1, 1000)
      table.sit(Player.new(5000), 3, 1000)
      table.sit(Player.new(5000), 5, 1000)
      table.sit(Player.new(5000), 7, 1000)
      winners, best_hand = table.run_hand
      #table.dump_hands
      assert_equal(winners, [5])

      table = Table.new(10, 89)
      # 7's full of 4's
      table.sit(Player.new(5000), 1, 1000)
      table.sit(Player.new(5000), 3, 1000)
      table.sit(Player.new(5000), 5, 1000)
      table.sit(Player.new(5000), 7, 1000)
      winners, best_hand = table.run_hand
      #table.dump_hands
      assert_equal(winners, [5])
    end
  end
end
