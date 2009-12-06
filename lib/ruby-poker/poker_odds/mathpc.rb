class Integer
  def factorial
    (2..self).inject(1) { |f, n| f * n }
  end

  def p(r)
    self.factorial / (self - r).factorial
  end

  def c(m)
    self.factorial / (m.factorial * (self - m).factorial)
  end

  def cf(m)
    self.gosper / (m.to_f.gosper * (self - m).gosper)
  end

  # quick, accurate approximation to factorial
  # gleaned from http://mathworld.wolfram.com/StirlingsApproximation.html
  def gosper
    Math.sqrt( ((2*self) + (1.0/3))*Math::PI ) * ((self/Math::E)**self).round
  end
end

if $0 == __FILE__
  puts "52c4 = #{52.c(4)}"
  puts "52c2 * 50c2 = #{52.c(2) * 50.c(2)}"
  puts "52p4 = #{52.p(4)}"
  puts "52p2 * 50p2 = #{52.p(2) * 50.p(2)}"
end
