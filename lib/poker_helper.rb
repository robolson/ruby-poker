module PokerHelper
  # Returns array of elements that only occur once
  # [1, 1, 2, 3] => [2, 3]
  def singles array1
    counts = Hash.new(0)
    array1.each do |value|
      counts[value] += 1
    end

    return counts.collect {|key,value| value == 1 ? key : nil }.compact.sort
  end
  
  # Returns an array containing values that we duplicated in the original array
  # [1, 2, 3, 1] => [1]
  def duplicates array1
    counts = Hash.new(0)
    array1.each do |value|
      counts[value] += 1
    end

    return counts.collect {|key,value| value > 1 ? key : nil }.compact.sort
  end
end # module ArrayHelper