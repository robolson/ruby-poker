require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestFullHouse < Test::Unit::TestCase
  include ClassReferences

  context "A Full House should return the correct cards from sort_using_rank" do

    setup do
      @fh_high_pair = poker_hand_class.new("8h 8d 8c Qh Td Kd Ks")
      @fh_low_pair = poker_hand_class.new("8h 8d 8c Qh Td 4h 4d")
      @fh_high_trips = poker_hand_class.new("Kh Kd Kc Qh Td 8h 8d")
      @fh_low_trips = poker_hand_class.new("4h 4d 4c Qh Td Kd Ks")
    end

    should "full house #sort_using_rank from seven cards (high pair) should return correct cards" do
      assert_equal("8h 8d 8c Ks Kd Qh Td", @fh_high_pair.sort_using_rank)
    end

    should "full house #sort_using_rank from seven cards (low pair) should return correct cards" do
      assert_equal("8h 8d 8c 4h 4d Qh Td", @fh_low_pair.sort_using_rank)
    end

    should "full house #sort_using_rank from seven cards (high trips) should return correct cards" do
      assert_equal("Kh Kd Kc 8h 8d Qh Td", @fh_high_trips.sort_using_rank)
    end

    should "full house #sort_using_rank from seven cards (low trips) should return correct cards" do
      assert_equal("4h 4d 4c Ks Kd Qh Td", @fh_low_trips.sort_using_rank)
    end

  end

end
