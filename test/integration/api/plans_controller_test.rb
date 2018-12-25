# frozen_string_literal: true

require 'test_helper'

class Api::PlansControllerTest < ActionDispatch::IntegrationTest

  setup do
    login! current_account
    @plan = current_account.provided_plans.first!
  end

  class ProviderLoggedInTest < Api::PlansControllerTest

    test 'publish/hide works independently' do
      post hide_admin_plan_path(plan)
      assert_response :redirect
      assert plan.reload.hidden?
    end

    private

    def current_account
      @provider ||= FactoryBot.create(:provider_account)
    end
  end

  class MasterLoggedInTest < Api::PlansControllerTest
    test 'publish/hide works for saas' do
      post hide_admin_plan_path(plan)
      assert_response :redirect
      assert plan.reload.hidden?

      post publish_admin_plan_path(plan)
      assert_response :redirect
      assert plan.reload.published?
    end

    test 'publish/hide is not authorized for on-premises' do
      ThreeScale.stubs(master_on_premises?: true)
      post hide_admin_plan_path(plan)
      assert_response :forbidden

      post publish_admin_plan_path(plan)
      assert_response :forbidden
    end

    private

    def current_account
      master_account
    end
  end

  private

  attr_reader :plan
end
