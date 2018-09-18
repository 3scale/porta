ActiveSupport::TestCase.class_eval do
  private

  def assert_json(expected, json = @response.body)
    assert json
    assert_equal expected, ActiveSupport::JSON.decode(json)
  end

  def assert_json_contains(expected, json = @response.body)
    assert json
    decoded = ActiveSupport::JSON.decode(json)
    flunk('No JSON input - nil after decode') if decoded.nil?

    expected.each do |key, value|
      assert_equal value, decoded[key]
    end
  end
end
