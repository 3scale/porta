# frozen_string_literal: true
require 'test_helper'

class CallableTest < ActiveSupport::TestCase
  class DummyCallableClass
    include Callable

    def initialize(args, &block)
      @args = args
      @block = block
    end

    def call
      @block.present? ? @block.call : @args
    end
  end

  test 'Callable makes .new private' do
    assert DummyCallableClass.private_methods(false).include?(:new)
  end

  test 'Callable exposes .call when included' do
    assert DummyCallableClass.public_methods(false).include?(:call)
  end

  test '.call executes #call with all available arguments' do
    arguments = { foo: 'foo', bar: 'bar' }

    assert_equal DummyCallableClass.call(arguments), arguments
  end

  test '.call accepts a block' do
    assert_equal DummyCallableClass.call(nil) { 1 + 1 }, 2
  end
end
