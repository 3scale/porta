# frozen_string_literal: true

require 'test_helper'

class Api::PricingRulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:simple_provider)
    @service = FactoryBot.create(:simple_service, account: provider)
    @plan = FactoryBot.create(:application_plan, issuer: service)
    @metric = FactoryBot.create(:metric, owner: service)
    @pricing_rule = FactoryBot.create(:pricing_rule, plan: plan, metric: metric, min: 1, max: 50)
  end

  attr_reader :provider, :user, :service, :plan, :metric, :pricing_rule

  class ProviderAdminTest < self
    setup do
      @user = FactoryBot.create(:admin, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'index' do
      other_metric = FactoryBot.create(:metric, owner: service, friendly_name: 'Other metric')
      other_pricing_rule = FactoryBot.create(:pricing_rule, plan: plan, metric: other_metric, min: 1, max: nil)

      get admin_application_plan_metric_pricing_rules_path(plan, metric), xhr: true
      assert_response :success
      response_body = response.body
      assert_match "<tr id=\\\"pricing_rule_#{pricing_rule.id}\\\">", response_body
      assert_not_match "<tr id=\\\"pricing_rule_#{other_pricing_rule.id}\\\">", response_body
    end

    test 'new' do
      get new_admin_application_plan_metric_pricing_rule_path(plan, metric), xhr: true
      assert_response :success
    end

    test 'create' do
      assert_difference -> { PricingRule.where(plan: plan, metric: metric).count } do
        post admin_application_plan_metric_pricing_rules_path(plan, metric), xhr: true, params: pricing_rule_params
        assert_response :success
      end
    end

    test 'edit' do
      get edit_admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true
      assert_response :success
      assert_equal pricing_rule, assigns(:pricing_rule)
    end

    test 'update' do
      put admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true, params: pricing_rule_params
      assert_response :success
      assert_equal 0.05, pricing_rule.reload.cost_per_unit
    end

    test 'destroy' do
      delete admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true
      assert_response :success
      assert_raise(ActiveRecord::RecordNotFound) { pricing_rule.reload }
    end
  end

  class ProviderMemberTest < self
    setup do
      @user = FactoryBot.create(:member, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'member missing right permission' do
      get admin_application_plan_metric_pricing_rules_path(plan, metric), xhr: true
      assert_response :forbidden

      get new_admin_application_plan_metric_pricing_rule_path(plan, metric), xhr: true
      assert_response :forbidden

      post admin_application_plan_metric_pricing_rules_path(plan, metric), xhr: true, params: pricing_rule_params
      assert_response :forbidden

      get edit_admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true
      assert_response :forbidden

      put admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true, params: pricing_rule_params
      assert_response :forbidden

      delete admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true
      assert_response :forbidden
    end

    test 'member with right permission and access to all services' do
      user.admin_sections = %w[plans]
      user.save!

      get admin_application_plan_metric_pricing_rules_path(plan, metric), xhr: true
      assert_response :success

      get new_admin_application_plan_metric_pricing_rule_path(plan, metric), xhr: true
      assert_response :success

      post admin_application_plan_metric_pricing_rules_path(plan, metric), xhr: true, params: pricing_rule_params
      assert_response :success

      get edit_admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true
      assert_response :success

      put admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true, params: pricing_rule_params
      assert_response :success

      delete admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true
      assert_response :success
    end

    test 'member with right permission and restricted access to services' do
      forbidden_service = FactoryBot.create(:simple_service, account: provider)
      user.admin_sections = %w[plans]
      user.member_permission_service_ids = [service.id]
      user.save!

      forbidden_service = FactoryBot.create(:simple_service, account: provider)
      forbidden_plan = FactoryBot.create(:application_plan, issuer: forbidden_service)
      forbidden_metric = FactoryBot.create(:metric, owner: forbidden_service)
      forbidden_pricing_rule = FactoryBot.create(:pricing_rule, plan: forbidden_plan, metric: forbidden_metric, min: 1, max: 50)

      get admin_application_plan_metric_pricing_rules_path(forbidden_plan, forbidden_metric), xhr: true
      assert_response :not_found

      get new_admin_application_plan_metric_pricing_rule_path(forbidden_plan, forbidden_metric), xhr: true
      assert_response :not_found

      post admin_application_plan_metric_pricing_rules_path(forbidden_plan, forbidden_metric), xhr: true, params: pricing_rule_params
      assert_response :not_found

      get edit_admin_application_plan_pricing_rule_path(forbidden_plan, forbidden_pricing_rule), xhr: true
      assert_response :not_found

      put admin_application_plan_pricing_rule_path(forbidden_plan, forbidden_pricing_rule), xhr: true, params: pricing_rule_params
      assert_response :not_found

      delete admin_application_plan_pricing_rule_path(forbidden_plan, forbidden_pricing_rule), xhr: true
      assert_response :not_found

      get admin_application_plan_metric_pricing_rules_path(plan, metric), xhr: true
      assert_response :success

      get new_admin_application_plan_metric_pricing_rule_path(plan, metric), xhr: true
      assert_response :success

      post admin_application_plan_metric_pricing_rules_path(plan, metric), xhr: true, params: pricing_rule_params
      assert_response :success

      get edit_admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true
      assert_response :success

      put admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true, params: pricing_rule_params
      assert_response :success

      delete admin_application_plan_pricing_rule_path(plan, pricing_rule), xhr: true
      assert_response :success
    end
  end

  protected

  def pricing_rule_params
    { pricing_rule: { min: 51, max: '', cost_per_unit: '0.05' } }
  end
end
