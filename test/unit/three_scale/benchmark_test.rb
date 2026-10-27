# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class ThreeScale::BenchmarkTest < ActiveSupport::TestCase
  class MeasuredOperation
    include ThreeScale::Benchmark

    attr_accessor :logger
  end

  test 'returns the block result and logs the duration in milliseconds' do
    output = StringIO.new
    operation = MeasuredOperation.new
    operation.logger = Logger.new(output)
    calls = 0
    value = Object.new

    assert_same value, operation.benchmark('request') { calls += 1; value }
    assert_equal 1, calls
    assert_match(/request \(\d+\.\dms\)/, output.string)
  end

  test 'runs the block once and returns its result without a logger' do
    operation = MeasuredOperation.new
    calls = 0

    assert_equal :result, operation.benchmark('request') { calls += 1; :result }
    assert_equal 1, calls
  end

  test 'propagates errors raised by the block' do
    operation = MeasuredOperation.new
    operation.logger = Logger.new(StringIO.new)

    error = assert_raises(RuntimeError) { operation.benchmark('request') { raise 'failed' } }
    assert_equal 'failed', error.message
  end
end
