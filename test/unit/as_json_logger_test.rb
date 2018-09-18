require 'test_helper'

class AsJsonLoggerTest < ActiveSupport::TestCase

  def test_as_json
    assert String, Rails.logger.as_json
  end
end
