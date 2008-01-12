#!/usr/bin/env ruby
require 'test/unit'
require 'rubygems'
require '../lib/ruby-poker'

class TestPokerHand < Test::Unit::TestCase
  def setup
    @hand1 = PokerHand.new("6D 7C 5D 5H 3S")
    @hand2 = PokerHand.new(["5C", "JC", "2H", "5S", "3D"])
  end
  
  def test_comparable
    assert_equal(-1, @hand1 <=> @hand2)
  end
end