module TestHelpers
  module AssertContentType
    private

    def assert_content_type(expected)
      assert_equal expected, @response.content_type
    end
  end
end

ActionController::TestCase.send(:include, TestHelpers::AssertContentType)
ActionDispatch::IntegrationTest.send(:include, TestHelpers::AssertContentType)
