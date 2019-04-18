# frozen_string_literal: true

class Segment::ResponseError < StandardError
  def initialize(message, response)
    super(message)
    @response = response
  end

  attr_reader :response
end
