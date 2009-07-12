require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestPokerHand < Test::Unit::TestCase
  context "A PokerHand instance" do
  
    setup do
      @trips = PokerHand.new("2D 9C AS AH AC")
      @full_boat = PokerHand.new(["2H", "2D", "4C", "4D", "4S"])
      @flush = PokerHand.new("3D 6D 7D TD QD 5H 2S")
      @straight = PokerHand.new("8H 9D TS JH QC AS")
    end
  
    # there are a lot of combinations that should be tested here. I will add more
    # troublesome cases as I think of them.
    should "sort using rank" do
      assert_equal("As Ah Ac 9c 2d", @trips.sort_using_rank)
      assert_equal("4s 4d 4c 2h 2d", @full_boat.sort_using_rank)
      assert_equal("Qd Td 7d 6d 3d 2s 5h", @flush.sort_using_rank)
      assert_equal("Qc Jh Ts 9d 8h As", @straight.sort_using_rank)
    
      assert_equal("As Ah 3d 3c Kd", PokerHand.new("AS AH KD 3D 3C").sort_using_rank)
      assert_equal("As Ah 3d 3c 2d", PokerHand.new("2D AS AH 3D 3C").sort_using_rank)
    end

    should "return card sorted by face value" do
      assert_equal([13, 13, 13, 8, 1], @trips.by_face.hand.collect {|c| c.face})
    end

    should "return cards sorted by suit" do
      assert_equal([3, 2, 1, 0, 0], @trips.by_suit.hand.collect {|c| c.suit})
    end

    should "return just the face values of the cards" do
      assert_equal([1, 8, 13, 13, 13], @trips.face_values)
    end
    
    should "recognize a straight flush" do
      assert !@flush.straight_flush?
      assert !@straight.straight_flush?
      assert PokerHand.new("8H 9H TH JH QH AS").straight_flush?
    end
  
    should "recognize a royal flush" do
      assert !@flush.royal_flush?
      assert PokerHand.new("AD KD QD JD TD").royal_flush?
    end

    should "recognize a flush" do
      assert @flush.flush?
      assert !@trips.flush?
    end

    should "recognize a four of a kind" do
      assert !@trips.four_of_a_kind?
      assert PokerHand.new("AD 9C AS AH AC")
    end

    should "recognize a full house" do
      assert !@trips.full_house?
      assert @full_boat.full_house?
    end
    
    should "recognize a straight" do
      assert @straight.straight?
      assert PokerHand.new("AH 2S 3D 4H 5D").straight?
    end

    should "recognize a three of a kind" do
      assert @trips.three_of_a_kind?
    end

    should "recognize a two pair" do
      assert PokerHand.new("2S 2D TH TD 4S").two_pair?
      assert !PokerHand.new("6D 7C 5D 5H 3S").two_pair?
    end
    
    should "recognize a pair" do
      assert !PokerHand.new("5C JC 2H 7S 3D").pair?
      assert PokerHand.new("6D 7C 5D 5H 3S").pair?
    end
    
    should "recognize a hand with the rank highest_card" do
      # hard to test, make sure it does not return null
      assert PokerHand.new("2D 4S 6C 8C TH").highest_card?
    end

    should "have an instance variable hand that is an array of Cards" do
      assert_instance_of Card, @trips.hand[0]
    end

    should "return the hand's rating as a string" do
      assert_equal "Three of a kind", @trips.hand_rating
      assert_equal "Full house", @full_boat.hand_rating
    end

    should "respond to rank" do
      # rank is an alias for hand_rating
      assert_respond_to @trips, :rank
    end

    should "return the hand as a string" do
      assert_equal("2d 9c As Ah Ac", @trips.just_cards)
    end

    should "return the hand's score" do
      assert_equal([4, 13, 8, 1], @trips.score[0])
    end

    should "be able to match regular expressions" do
      assert_match(/9c/, @trips.to_s)
      assert_no_match(/AD/, @trips.to_s)
    end
  
    should "return the correct number of cards in the hand" do
      assert_equal(0, PokerHand.new.size)
      assert_equal(1, PokerHand.new("2c").size)
      assert_equal(2, PokerHand.new("2c 3d").size)
    end
  
    should "be comparable to other PokerHands" do
      hand1 = PokerHand.new("5C JC 2H 5S 3D")
      hand2 = PokerHand.new("6D 7C 5D 5H 3S")
      assert_equal(1, hand1 <=> hand2)
      assert_equal(-1, hand2 <=> hand1)
    end
  
    should "be considered equal to other poker hands that contain the same cards" do
      assert_equal(0, @trips <=> @trips)
    
      hand1 = PokerHand.new("Ac Qc Ks Kd 9d 3c")
      hand2 = PokerHand.new("Ah Qs 9h Kh Kc 3s")
      assert_equal(0, hand1 <=> hand2)
    end
  
    should "be able to add a Card to itself" do
      ph = PokerHand.new()
      ph << "Qd"
      ph << Card.new("2D")
      ph << ["3d", "4d"]
      assert_equal("Qd 2d 3d 4d", ph.just_cards)
    end
  
    should "be able to delete a card" do
      ph = PokerHand.new("Ac")
      ph.delete("Ac")
      assert_equal(Array.new, ph.hand)
    end
    
    should "detect the two highest pairs when there are more than two" do
      ph = PokerHand.new("7d 7s 4d 4c 2h 2d")
      assert_equal([3, 6, 3, 1], ph.two_pair?[0])
      # Explanation of [3, 6, 3, 1]
      # 3: the number for a two pair
      # 6: highest pair is two 7's
      # 3: second highest pair is two 4's
      # 1: kicker is a 2
    end
  
    context "when duplicates are allowed" do
      setup do
        PokerHand.allow_duplicates = true
      end
    
      should "create a PokerHand of unique cards" do
        uniq_ph = PokerHand.new("3s 4s 3s").uniq
        assert_instance_of(PokerHand, uniq_ph)  # want to be sure uniq hands back a PokerHand
        assert_contains(uniq_ph.hand, Card.new('3s'))
        assert_contains(uniq_ph.hand, Card.new('4s'))
      end
    
      should "allow five of a kind" do
        # there is no five of a kind. This just tests to make sure
        # that ruby-poker doesn't crash if given 5 of the same card
        ph = PokerHand.new("KS KS KS KS KS")
        assert_equal("Four of a kind", ph.rank)
      end
  
      should "allow duplicates on initialize" do
        assert_nothing_raised RuntimeError do
          PokerHand.new("3s 3s")
        end
      end
    
      should "allow duplicate card to be added after initialize" do
        ph = PokerHand.new("2d")
        ph << "2d"
        assert_equal("2d 2d", ph.just_cards)
      end
    end
  
    context "when duplicates are not allowed" do
      setup do
        PokerHand.allow_duplicates = false
      end
  
      should "not allow duplicates on initialize" do
        PokerHand.allow_duplicates = false
    
        assert_raise RuntimeError do
          PokerHand.new("3s 3s")
        end
    
        PokerHand.allow_duplicates = true
      end
    
      should "not allow duplicates after initialize" do
        PokerHand.allow_duplicates = false
    
        ph = PokerHand.new("2d")    
        assert_raise RuntimeError do
          ph << "2d"
        end
    
        PokerHand.allow_duplicates = true
      end
    end
    
  end
end

