class ResponseCode
  attr_reader :code

  def initialize(code)
    @code = code
  end

  def to_param
    @code
  end
end
