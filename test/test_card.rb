require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestCard < Test::Unit::TestCase
  def setup
    # testing various input formats for cards
    @c1 = Card.new("9c")
    @c2 = Card.new("TD")
    @c3 = Card.new("jh")
    @c4 = Card.new("qS")
  end

  def test_class_face_value
    assert_nil(Card.face_value('L'))
    assert_equal(13, Card.face_value('A'))
  end

  def test_build_from_card
    assert_equal("9c", Card.new(@c1).to_s)
  end

  def test_build_from_value
    assert_equal(@c1, Card.new(7))
    assert_equal(@c2, Card.new(22))
    assert_equal(@c3, Card.new(37))
    assert_equal(@c4, Card.new(52))
  end

  def test_build_from_face_suit
    assert_equal(7, Card.new('9', 'c').value)
    assert_equal(22, Card.new('T', 'd').value)
    assert_equal(37, Card.new('J', 'h').value)
    assert_equal(52, Card.new('Q', 's').value)
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

  def test_natural_value
    assert_equal(1, Card.new("AC").natural_value)
    assert_equal(15, Card.new("2D").natural_value)
    assert_equal(52, Card.new("KS").natural_value)
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
end