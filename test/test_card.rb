require 'test/unit'
require 'card.rb'

class TestCard < Test::Unit::TestCase
  def setup
    # testing various input formats for cards
    @c1 = Card.new("9c")
    @c2 = Card.new("TD")
    @c3 = Card.new("jh")
    @c4 = Card.new("qS")
  end
  
  def test_build_from_card
    c1 = Card.new("2c")
    c2 = Card.new(c1)
    assert_equal("2c", c2.to_s)
  end
  
  def test_class_face_value
    assert_equal(0, Card.face_value('L'))
    assert_equal(13, Card.face_value('A'))
  end

  def test_face
    assert_equal(8, @c1.face)
    assert_equal(9, @c2.face)
    assert_equal(10, @c3.face)
    assert_equal(11, @c4.face)          
  end

  def test_suit
    assert_equal(0, @c1.suit)
    assert_equal(1, @c2.suit)
    assert_equal(2, @c3.suit)
    assert_equal(3, @c4.suit)
  end

  def test_value
    assert_equal(7, @c1.value)
    assert_equal(22, @c2.value)
    assert_equal(37, @c3.value)
    assert_equal(52, @c4.value)
  end
  
  def test_comparison
    assert(@c1 < @c2)
    assert(@c3 > @c2)
  end
  
  def test_equals
    c = Card.new("9h")
    assert_not_equal(@c1, c)
    assert_equal(@c1, @c1)
  end
  
  def test_hash
    assert_equal(15, @c1.hash)
  end
end