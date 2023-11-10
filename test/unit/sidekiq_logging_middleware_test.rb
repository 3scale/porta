# frozen_string_literal: true

require 'test_helper'

class SidekiqLoggingMiddlewareTest < ActiveSupport::TestCase
  test 'filter sensitive arguments' do
    middleware = ThreeScale::SidekiqLoggingMiddleware.new
    msg = {
      'jid' => 123,
      'args' => [
        {
          "some_arg" => "value",
          "user_key" => "secret_value"
        }
      ]
    }

    Rails.logger.expects(:info).with('Enqueued DummyWorker#123 with args: [{"some_arg"=>"value", "user_key"=>"[FILTERED]"}]')

    middleware.call('DummyWorker', msg) { nil }
  end

  test 'do not filter plain arrays arguments' do
    middleware = ThreeScale::SidekiqLoggingMiddleware.new
    msg = {
      'jid' => 123,
      'args' => [
        'some_arg',
        [1, 2, 3, 4, 5]
      ]
    }

    Rails.logger.expects(:info).with('Enqueued DummyWorker#123 with args: ["some_arg", [1, 2, 3, 4, 5]]')

    middleware.call('DummyWorker', msg) { nil }
  end
end
