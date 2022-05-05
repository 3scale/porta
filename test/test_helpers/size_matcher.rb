class SizeMatcher
  def initialize(size)
    @size = size
  end

  def =~(enumerable)
    @size == enumerable.try(:size)
  end

  def inspect
    "SizeMatcher:#{@size}"
  end
end
