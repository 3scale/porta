# frozen_string_literal: true

class SimpleMiniTest < ActiveSupport::TestCase
  def teardown
    super
    User.current = nil
  end
end
