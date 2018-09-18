module RangeHacks
  # Get +index+'th subinterval out of +count+ in total.
  def subinterval(index, count)
    # Note: This is not ideal partitioning, but I don't have time to mess with it any more.
    # It's good enough.

    total_length = self.end - self.begin + 1
    sub_length = total_length.div(count)

    sub_begin = self.begin + index * sub_length
    sub_end = (index == count - 1) ? self.end : (sub_begin + sub_length - 1)

    sub_begin..sub_end
  end
end

Range.send(:include, RangeHacks)
