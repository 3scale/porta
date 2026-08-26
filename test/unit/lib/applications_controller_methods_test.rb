# frozen_string_literal: true

require 'test_helper'

class ApplicationsControllerMethodsTest < ActiveSupport::TestCase

  class TestController
    attr_accessor :params

    def initialize
      @params = ActionController::Parameters.new
    end

    def self.helper_method(*_methods)
      # Stub for controller helper_method
    end

    include ApplicationsControllerMethods
  end

  setup do
    @controller = TestController.new
  end

  class PlanIdTest < ApplicationsControllerMethodsTest
    test 'plan_id returns the plan_id from cinstance params for simple values' do
      @controller.params = ActionController::Parameters.new(cinstance: { plan_id: '123' })

      result = @controller.send(:plan_id)

      assert_equal '123', result
    end

    test 'plan_id raises error when plan_id is missing or is an array or object' do
      @controller.params = ActionController::Parameters.new(cinstance: {})
      assert_raises(ActionController::ParameterMissing) do
        @controller.send(:plan_id)
      end

      @controller.params = ActionController::Parameters.new(cinstance: { plan_id: %w[1 2 3] })
      assert_raises(ActionController::ParameterMissing) do
        @controller.send(:plan_id)
      end

      @controller.params = ActionController::Parameters.new(cinstance: { plan_id: { invalid: 'param' }})
      assert_raises(ActionController::ParameterMissing) do
        @controller.send(:plan_id)
      end
    end
  end
end
