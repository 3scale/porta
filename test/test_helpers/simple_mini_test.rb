# frozen_string_literal: true

class SimpleMiniTest < Minitest::Test
  def teardown
    super
    User.current = nil
    travel_back
  end
end
