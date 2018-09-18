class TestOutputBuffer
  attr_reader :output

  def initialize
    @output = ''.html_safe
  end

  def concat(value)
    @output << value.html_safe
  end

  def output
    @output.html_safe
  end
end
