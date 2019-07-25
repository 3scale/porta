require 'webmock'
require 'webmock/minitest'

module WebMock
  class << self
    attr_accessor :last_request
  end
end

WebMock.after_request do |request, _response|
  WebMock.last_request = request
end

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

    def assert_last_request(method, options = {})
      assert_equal method.downcase.to_sym, ::WebMock.last_request.method
      assert_equal options[:path],         ::WebMock.last_request.uri.request_uri if options[:path]
      assert_equal options[:body],         ::WebMock.last_request.body            if options[:body]
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::WebMock)
