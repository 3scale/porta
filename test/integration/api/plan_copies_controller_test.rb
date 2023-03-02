# frozen_string_literal: true

require 'test_helper'

class Api::PlanCopiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    login! current_account
    @plan = current_account.provided_plans.first!
  end

  class ProviderLoggedInTest < Api::PlanCopiesControllerTest
    def setup
      Logic::RollingUpdates.stubs(skipped?: true)
    end

    test '#create should make a copy and return it in a JSON' do
      [true, false].each do |onpremises|
        ThreeScale.config.stubs(onpremises: onpremises)
        assert_difference(current_account.provided_plans.method(:count), + 1) do
          post admin_plan_copies_path(plan_id: plan.id)
          assert_plan_copied
        end
      end
    end

    test '#create copy not persisted' do
      Plan.any_instance.stubs(:persisted?).returns(false)
      post admin_plan_copies_path(plan_id: plan.id)
      assert_plan_not_copied
    end

    test '#create copy not saved' do
      Plan.any_instance.stubs(:save).returns(false)
      post admin_plan_copies_path(plan_id: plan.id)
      assert_plan_not_copied
    end

    test '#create should make a copy with no contracts' do
      Plan.update_counters plan.id, contracts_count: 25 # rubocop:disable Rails/SkipsModelValidations
      plan.reload
      assert_equal 25, plan.contracts_count

      post admin_plan_copies_path(plan_id: plan.id)
      assert_plan_copied
      assert_equal 0, current_account.provided_plans.last.contracts_count
    end

    private

    def current_account
      @provider ||= FactoryBot.create(:provider_account)
    end
  end

  class MasterLoggedInTest < Api::PlanCopiesControllerTest
    test '#create works for Saas but it is unauthorized for on-premises' do
      # Saas is the default
      assert_difference(current_account.provided_plans.method(:count), + 1) do
        post admin_plan_copies_path(plan_id: plan.id)
        assert_plan_copied
      end

      # On-premises
      ThreeScale.config.stubs(onpremises: true)
      assert_no_difference(current_account.provided_plans.method(:count)) do
        post admin_plan_copies_path(plan_id: plan.id)
        assert_response :forbidden
      end
    end

    private

    def current_account
      master_account
    end
  end

  private

  attr_reader :plan

  def assert_plan_copied
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 'Plan copied.', json['notice']
    assert_includes current_account.provided_plans.pluck(:id), JSON.parse(json['plan'])['id']
  end

  def assert_plan_not_copied
    assert_response :unprocessable_entity
    assert_equal 'Plan could not be copied.', JSON.parse(response.body)['error']
  end
end
