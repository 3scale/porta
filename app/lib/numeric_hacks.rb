module NumericHacks
  # What is the change (in percents) of this value from the other value.
  #
  # == Example
  #
  #   10.percentage_change_from(5)  # 100.0
  #   11.percentage_change_from(10) # 10.0
  #   20.percentage_change_from(40) # -50.0
  #
  def percentage_change_from(other)
    (self - other).percentage_ratio_of(other)
  end

  # How many percents of the other value is this value.
  #
  # == Example
  #
  #   10.percentage_ratio_of(10)  # 100.0
  #   5.percentage_ratio_of(10)   # 50.0
  #   0.1.percentage_ratio_of(10) # 1.0
  def percentage_ratio_of(other)
    if self.zero? && other.zero?
      0.0
    elsif other.zero?
      100.0
    else
      (self.to_f / other) * 100.0
    end
  end
end

Numeric.send(:include, NumericHacks)
