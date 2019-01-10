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

    test '#create should render a create template and make the copy' do
      [true, false].each do |onpremises|
        ThreeScale.config.stubs(onpremises: onpremises)
        assert_difference(current_account.provided_plans.method(:count), + 1) do
          post admin_plan_copies_path(plan_id: plan.id, format: :js)
          assert_response :ok
          assert_template 'api/plan_copies/create'
        end
      end
    end

    test '#create should render a new template if not persisted' do
      Plan.any_instance.stubs(:persisted?).returns(false)
      post admin_plan_copies_path(plan_id: plan.id, format: :js)
      assert_response :ok
      assert_template 'api/plan_copies/new'
    end

    test '#create should make a copy with a default contracts_count value' do
      Plan.update_counters plan.id, contracts_count: 25
      plan.reload
      assert_equal 25, plan.contracts_count
      post admin_plan_copies_path(plan_id: plan.id, format: :js)
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
        post admin_plan_copies_path(plan_id: plan.id, format: :js)
        assert_response :ok
      end

      # On-premises
      ThreeScale.config.stubs(onpremises: true)
      assert_no_difference(current_account.provided_plans.method(:count)) do
        post admin_plan_copies_path(plan_id: plan.id, format: :js)
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
end
