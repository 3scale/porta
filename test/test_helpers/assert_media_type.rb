module TestHelpers
  module AssertMediaType
    private

    def assert_media_type(expected)
      assert_equal expected, @response.media_type
    end
  end
end

ActionController::TestCase.send(:include, TestHelpers::AssertMediaType)
ActionDispatch::IntegrationTest.send(:include, TestHelpers::AssertMediaType)
