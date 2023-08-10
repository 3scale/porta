# frozen_string_literal: true

class SegmentIntegration::ResponseError < StandardError
  def initialize(message, response)
    super(message)
    @response = response
  end

  attr_reader :response
end
