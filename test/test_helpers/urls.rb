module TestHelpers
  module Urls
    private

    def assert_current_path(path)
      assert_equal path, page.current_path
    end
  end
end

ActionDispatch::IntegrationTest.send(:include, TestHelpers::Urls)
