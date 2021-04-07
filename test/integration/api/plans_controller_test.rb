# frozen_string_literal: true

require 'test_helper'

class Api::PlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    login! current_account
    @plan = current_account.provided_plans.first!
  end

  class ProviderLoggedInTest < self
    test 'publish/hide works independently' do
      post hide_admin_plan_path(plan)
      assert_response :redirect
      assert plan.reload.hidden?
    end

    test 'publishing a published application plan' do
      app_plan = FactoryBot.create(:published_plan, issuer: current_account.default_service)
      post publish_admin_plan_path(app_plan)
      assert_response :not_acceptable
    end

    test 'publishing a service plan and redirecting back to google' do
      service_plan = FactoryBot.create(:service_plan, issuer: current_account.default_service)
      post publish_admin_plan_path(service_plan), headers: { 'HTTP_REFERER' => 'http://google.com' }
      assert_response :redirect
      assert_redirected_to 'http://google.com'
      assert flash[:notice]
      assert assigns(:plan).published?
    end

    test 'hiding an account plan' do
      post hide_admin_plan_path(current_account.default_account_plan)
      assert_response :redirect
      assert_redirected_to admin_account_plans_path
      assert flash[:notice]
      assert assigns(:plan).hidden?
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
