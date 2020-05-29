# frozen_string_literal: true

require 'test_helper'

class ThreeScale::Middleware::HandleParseErrorTest < ActiveSupport::TestCase
  test 'correct request params' do
    app = proc { perform_post_request(raw_post_data: '{ "foo" : "bar" }') }
    middleware = ThreeScale::Middleware::HandleParseError.new(app)

    expected_response = {'foo' => 'bar'}
    assert_equal expected_response, middleware.call({})
  end

  test 'invalid request params' do
    Rails.logger.expects(:error).with('Handling Exception: \'ActionDispatch::ParamsParser::ParseError\' with status 422')

    app = proc { perform_post_request(raw_post_data: '{ wrong: "invalid", ') }
    middleware = ThreeScale::Middleware::HandleParseError.new(app)

    assert_equal [422, {}, [nil]], middleware.call({})
  end

  private

  def perform_post_request(raw_post_data:)
    env = {
      'rack.input' => 'foo',
      'CONTENT_TYPE' => 'application/json',
      'CONTENT_LENGTH' => 9,
      'RAW_POST_DATA' => raw_post_data
    }
    request = ActionDispatch::Request.new(env)
    request.POST
  end
end
