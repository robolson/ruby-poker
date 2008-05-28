require 'test/unit'
require 'ruby-poker.rb'

class TestPokerHand < Test::Unit::TestCase
  def setup
    @trips = PokerHand.new("2D 9C AS AH AC")
    @full_boat = PokerHand.new(["2H", "2D", "4C", "4D", "4S"])
    @flush = PokerHand.new("3D 6D 7D TD QD 5H 2S")
    @straight = PokerHand.new("8H 9D TS JH QC AS")
  end
  
  # there are a lot of combinations that should be tested here. I will add more
  # troublesome cases as I think of them.
  def test_sort_using_rank
    assert_equal("As Ah Ac 9c 2d", @trips.sort_using_rank)
    assert_equal("4s 4d 4c 2h 2d", @full_boat.sort_using_rank)
    assert_equal("Qd Td 7d 6d 3d 2s 5h", @flush.sort_using_rank)
    assert_equal("Qc Jh Ts 9d 8h As", @straight.sort_using_rank)
    
    assert_equal("As Ah 3d 3c Kd", PokerHand.new("AS AH KD 3D 3C").sort_using_rank)
    assert_equal("As Ah 3d 3c 2d", PokerHand.new("2D AS AH 3D 3C").sort_using_rank)
  end

  def test_by_face
    assert_equal([13, 13, 13, 8, 1], @trips.by_face.hand.collect {|c| c.face})
  end

  def test_by_suit
    assert_equal([3, 2, 1, 0, 0], @trips.by_suit.hand.collect {|c| c.suit})
  end

  def test_face_values
    assert_equal([1, 8, 13, 13, 13], @trips.face_values)
  end

  def test_flush
    assert @flush.flush?
    assert !@trips.flush?
  end

  def test_four_of_a_kind
    assert !@trips.four_of_a_kind?
    assert PokerHand.new("AD 9C AS AH AC")
  end

  def test_full_house
    assert !@trips.full_house?
    assert @full_boat.full_house?
  end

  def test_hand
    assert_equal 5, @trips.hand.size
    assert_instance_of Card, @trips.hand[0]
  end

  def test_hand_rating
    assert_equal "Three of a kind", @trips.hand_rating
    assert_equal "Full house", @full_boat.hand_rating
  end

  def test_rank
    # rank is an alias for hand_rating
    assert_not_nil @trips.rank
  end

  def test_highest_card
    # hard to test, make sure it does not return null
    assert PokerHand.new("2D 4S 6C 8C TH").highest_card?
  end

  def test_just_cards
    assert_equal("2d 9c As Ah Ac", @trips.just_cards)
  end

  def test_pair
    assert !PokerHand.new("5C JC 2H 7S 3D").pair?
    assert PokerHand.new("6D 7C 5D 5H 3S").pair?
  end
  
  def test_royal_flush
    assert !@flush.royal_flush?
    assert PokerHand.new("AD KD QD JD TD").royal_flush?
  end

  def test_score
    assert_equal([4, 13, 8, 1], @trips.score[0])
  end

  def test_straight
    assert @straight.straight?
    assert PokerHand.new("AH 2S 3D 4H 5D").straight?
  end

  def test_straight_flush
    assert !@flush.straight_flush?
    assert !@straight.straight_flush?
    assert PokerHand.new("8H 9H TH JH QH AS").straight_flush?
  end

  def test_three_of_a_kind
    assert @trips.three_of_a_kind?
  end

  def test_two_pair
    assert PokerHand.new("2S 2D TH TD 4S").two_pair?
    assert !PokerHand.new("6D 7C 5D 5H 3S").two_pair?
  end
  
  def test_matching
    assert_match(/9c/, @trips)
  end
  
  def test_size
    assert_equal(2, PokerHand.new("2c 3d").size)
  end
  
  def test_comparisons
    hand1 = PokerHand.new("5C JC 2H 5S 3D")
    hand2 = PokerHand.new("6D 7C 5D 5H 3S")
    assert_equal(1, hand1 <=> hand2)
    assert_equal(-1, hand2 <=> hand1)
  end
  
  def test_equality
    assert_equal(0, @trips <=> @trips)
    
    hand1 = PokerHand.new("Ac Qc Ks Kd 9d 3c")
    hand2 = PokerHand.new("Ah Qs 9h Kh Kc 3s")
    assert_equal(0, hand1 <=> hand2)
  end
  
  def test_appending
    ph = PokerHand.new()
    ph << "Qd"
    ph << Card.new("2D")
    ph << ["3d", "4d"]
    assert_equal("Qd 2d 3d 4d", ph.just_cards)
  end
  
  def test_delete
    ph = PokerHand.new("Ac")
    ph.delete("Ac")
    assert_equal(Array.new, ph.hand)
  end
  
  def test_five_of_a_kind
    # there is no five of a kind. This just tests to make sure
    # that ruby-poker doesn't crash if given 5 of the same card
    ph = PokerHand.new("KS KS KS KS KS")
    assert_equal("Four of a kind", ph.rank)
  end
  
  def test_duplicates
    ph = PokerHand.new("2d")
    
    PokerHand.allow_duplicates = false
    assert_raise RuntimeError do
      ph << "2d"
    end
    assert_raise RuntimeError do
      PokerHand.new("3s 3s")
    end
    
    PokerHand.allow_duplicates = true   # default behavior
    ph << "2d"
    assert_equal("2d 2d", ph.just_cards)
  end
end

