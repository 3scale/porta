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
      assert_plan_hid plan
    end

    test 'publishing a published application plan' do
      app_plan = FactoryBot.create(:published_plan, issuer: current_account.default_service)
      post publish_admin_plan_path(app_plan)
      assert_not_plan_published app_plan
    end

    test 'hiding an account plan' do
      plan = current_account.default_account_plan
      post hide_admin_plan_path(plan)
      assert_plan_hid plan
    end

    private

    def current_account
      @provider ||= FactoryBot.create(:provider_account)
    end
  end

  class MasterLoggedInTest < Api::PlansControllerTest
    test 'publish/hide works for saas' do
      post hide_admin_plan_path(plan)
      assert_plan_hid plan

      post publish_admin_plan_path(plan)
      assert_plan_published plan
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

  def assert_plan_hid(plan)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Plan #{plan.name} was hidden.", json['notice']
    assert_equal plan.id, JSON.parse(json['plan'])['id']
    assert plan.reload.hidden?
  end

  def assert_plan_published(plan)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Plan #{plan.name} was published.", json['notice']
    assert_equal plan.id, JSON.parse(json['plan'])['id']
    assert plan.reload.published?
  end

  def assert_not_plan_published(plan)
    assert_response :not_acceptable
    json = JSON.parse(response.body)
    assert_equal "Plan #{plan.name} cannot be published.", json['error']
    assert_nil json['plan']
  end
end
