require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestCard < Test::Unit::TestCase
  include ClassReferences

  def setup
    # testing various input formats for cards
    @c1 = card_class.new("9c")
    @c2 = card_class.new("TD")
    @c3 = card_class.new("jh")
    @c4 = card_class.new("qS")
    @c5 = card_class.new("AC")
  end

  def test_class_face_value
    assert_equal(0,  card_class.face_value('L'))
    assert_equal(13, card_class.face_value('A'))
  end

  def test_build_from_card
    assert_equal("9c", card_class.new(@c1).to_s)
  end

  def test_build_from_value
    assert_equal(@c1, card_class.new(8))
    assert_equal(@c2, card_class.new(22))
    assert_equal(@c3, card_class.new(36))
    assert_equal(@c4, card_class.new(50))
    assert_equal(@c5, card_class.new(13))
  end

  def test_build_from_face_suit
    assert_equal(8, card_class.new('9', 'c').value)
    assert_equal(22, card_class.new('T', 'd').value)
    assert_equal(36, card_class.new('J', 'h').value)
    assert_equal(50, card_class.new('Q', 's').value)
    assert_equal(13, card_class.new('A', 'c').value)
  end

  def test_build_from_value_and_from_face_suit_match
    ticker = 0
    card_class::SUITS.each_char do |suit|
      "23456789TJQKA".each_char do |face|
        ticker += 1
        from_value = card_class.new(ticker)
        from_face_suit = card_class.new(face, suit)
        assert_equal(from_face_suit, from_value,
                     "Face and suit #{face + suit} did not match card from value #{ticker}")
      end
    end
  end

  def test_build_from_value_and_from_face_suit_values_match
    ticker = 0
    0.upto(3) do |suit|
      1.upto(13) do |face|
        ticker += 1
        from_value = card_class.new(ticker)
        from_face_suit_values = card_class.new(face, suit)
        assert_equal(from_face_suit_values, from_value,
                     "Face=#{face} and suit=#{suit} did not match card from value #{ticker}")
      end
    end
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
    assert_equal(8, @c1.value)
    assert_equal(22, @c2.value)
    assert_equal(36, @c3.value)
    assert_equal(50, @c4.value)
    assert_equal(13, @c5.value)
  end

  def test_natural_value
    assert_equal(1, card_class.new("AC").natural_value)
    assert_equal(15, card_class.new("2D").natural_value)
    assert_equal(52, card_class.new("KS").natural_value)
  end

  def test_comparison
    assert(@c1 < @c2)
    assert(@c3 > @c2)
  end

  def test_equals
    c = card_class.new("9h")
    assert_not_equal(@c1, c)
    assert_equal(@c1, @c1)
  end
end
