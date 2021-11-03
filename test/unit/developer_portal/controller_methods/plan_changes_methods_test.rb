require 'test_helper'

module DeveloperPortal::ControllerMethods
  class PlanChangesMethodsTest < ActiveSupport::TestCase

    class DummieController < ApplicationController
      include ::DeveloperPortal::ControllerMethods::PlanChangesMethods
    end

    def setup
      @controller         = DummieController.new
      @controller.request = ActionController::TestRequest.create(@controller)

      @store = @controller.send(:plan_changes_store)
    end

    def test_plan_changes_store
      assert @store, ::DeveloperPortal::ControllerMethods::PlanChangesMethods::PlanChangesStore
    end

    def test_plan_changes?
      refute @controller.send(:plan_changes?)

      @store.save(1, 2)

      assert @controller.send(:plan_changes?)
    end

    def test_store_plan_change!
      assert_nil @store[1]

      @controller.send(:store_plan_change!, 1, '')

      assert_nil @store[1]

      @controller.send(:store_plan_change!, 1, 2)

      assert_equal 2, @store[1]
    end

    def test_unstore_plan_change!
      assert_nil @store[1]

      @controller.send(:store_plan_change!, 1, 2)

      assert_equal 2, @store[1]

      @controller.send(:unstore_plan_change!, 1)

      assert_nil @store[1]
    end

    def test_plan_ids
      assert_equal [], @store.plan_ids

      @store.save(1, 2)

      assert_equal [2], @store.plan_ids
    end

    def test_contract_ids
      assert_equal [], @store.contract_ids

      @store.save(1, 2)

      assert_equal [1], @store.contract_ids
    end

    def test_fetch
      assert_nil @store[1]

      @store.save(1, 2)

      assert_equal 2, @store[1]
    end
  end
end
