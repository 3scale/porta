# frozen_string_literal: true

require 'test_helper'

class Api::UsageLimitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:simple_provider)
    @service = FactoryBot.create(:simple_service, account: provider)
    @plan = FactoryBot.create(:application_plan, issuer: service)
    @metric = FactoryBot.create(:metric, owner: service)
    @usage_limit = FactoryBot.create(:usage_limit, plan: plan, metric: metric, period: 'year', value: 50)
  end

  attr_reader :provider, :user, :service, :plan, :metric, :usage_limit

  class ProviderAdminTest < self
    setup do
      @user = FactoryBot.create(:admin, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'index' do
      other_metric = FactoryBot.create(:metric, owner: service, friendly_name: 'Other metric')
      other_usage_limit = FactoryBot.create(:usage_limit, plan: plan, metric: other_metric, period: 'eternity', value: 1000)

      get admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true
      assert_response :success
      response_body = response.body
      assert_match "<tr id=\\\"usage_limit_#{usage_limit.id}\\\">", response_body
      assert_not_match "<tr id=\\\"usage_limit_#{other_usage_limit.id}\\\">", response_body
    end

    test 'new' do
      get new_admin_application_plan_metric_usage_limit_path(plan, metric), xhr: true
      assert_response :success
    end

    test 'create' do
      assert_difference -> { UsageLimit.where(plan: plan, metric: metric).count } do
        post admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true, params: usage_limit_params
        assert_response :success
      end
    end

    test "create renders correcty the flash notices" do
      post admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true, params: usage_limit_params
      assert_response :success
      assert_equal 'Usage Limit has been created.', flash[:notice] # usage_limit created

      post admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true, params: usage_limit_params.deep_merge(usage_limit: { value: 300 })
      assert_response :success
      refute flash[:notice] # not created, same period for same metric

      post admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true, params: usage_limit_params.deep_merge(usage_limit: { period: 'day' })
      assert_response :success
      assert_equal 'Usage Limit has been created.', flash[:notice] # different period, ok
    end

    test 'edit' do
      get edit_admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true
      assert_response :success
      assert_equal usage_limit, assigns(:usage_limit)
    end

    test 'update' do
      put admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true, params: usage_limit_params
      assert_response :success
      assert_equal 150, usage_limit.reload.value
    end

    test 'destroy' do
      delete admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true
      assert_response :success
      assert_raise(ActiveRecord::RecordNotFound) { usage_limit.reload }
    end
  end

  class ProviderMemberTest < self
    setup do
      @user = FactoryBot.create(:member, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'member missing right permission' do
      get admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true
      assert_response :forbidden

      get new_admin_application_plan_metric_usage_limit_path(plan, metric), xhr: true
      assert_response :forbidden

      post admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true, params: usage_limit_params
      assert_response :forbidden

      get edit_admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true
      assert_response :forbidden

      put admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true, params: usage_limit_params
      assert_response :forbidden

      delete admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true
      assert_response :forbidden
    end

    test 'member with right permission and access to all services' do
      user.admin_sections = %w[plans]
      user.save!

      get admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true
      assert_response :success

      get new_admin_application_plan_metric_usage_limit_path(plan, metric), xhr: true
      assert_response :success

      post admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true, params: usage_limit_params
      assert_response :success

      get edit_admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true
      assert_response :success

      put admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true, params: usage_limit_params
      assert_response :success

      delete admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true
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
      forbidden_usage_limit = FactoryBot.create(:usage_limit, plan: forbidden_plan, metric: forbidden_metric, period: 'eternity', value: 1000)

      get admin_application_plan_metric_usage_limits_path(forbidden_plan, forbidden_metric), xhr: true
      assert_response :not_found

      get new_admin_application_plan_metric_usage_limit_path(forbidden_plan, forbidden_metric), xhr: true
      assert_response :not_found

      post admin_application_plan_metric_usage_limits_path(forbidden_plan, forbidden_metric), xhr: true, params: usage_limit_params
      assert_response :not_found

      get edit_admin_application_plan_usage_limit_path(forbidden_plan, forbidden_usage_limit), xhr: true
      assert_response :not_found

      put admin_application_plan_usage_limit_path(forbidden_plan, forbidden_usage_limit), xhr: true, params: usage_limit_params
      assert_response :not_found

      delete admin_application_plan_usage_limit_path(forbidden_plan, forbidden_usage_limit), xhr: true
      assert_response :not_found

      get admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true
      assert_response :success

      get new_admin_application_plan_metric_usage_limit_path(plan, metric), xhr: true
      assert_response :success

      post admin_application_plan_metric_usage_limits_path(plan, metric), xhr: true, params: usage_limit_params
      assert_response :success

      get edit_admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true
      assert_response :success

      put admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true, params: usage_limit_params
      assert_response :success

      delete admin_application_plan_usage_limit_path(plan, usage_limit), xhr: true
      assert_response :success
    end
  end

  protected

  def usage_limit_params
    { usage_limit: { period: 'eternity', value: 150 } }
  end
end
