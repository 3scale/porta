require 'webmock'
require 'webmock/minitest'

module TestHelpers
  module WebMock
    def self.included(base)
      base.setup(:setup_web_mock)
      base.teardown(:teardown_web_mock)
    end

    # Helpers
    #
    def setup_web_mock
    end

    def teardown_web_mock
      ::WebMock.reset!
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::WebMock)
