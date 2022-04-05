# frozen_string_literal: true

require 'test_helper'

class Api::MetricVisibilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:simple_provider)
    @service = FactoryBot.create(:simple_service, account: provider)
    @plan = FactoryBot.create(:application_plan, issuer: service)
    @metric = FactoryBot.create(:metric, owner: service)
  end

  attr_reader :provider, :user, :service, :plan, :metric

  class ProviderAdminTest < self
    setup do
      @user = FactoryBot.create(:admin, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'toggle visible' do
      assert metric.visible_in_plan?(plan)

      put toggle_visible_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success
      refute metric.visible_in_plan?(plan)

      put toggle_visible_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success
      assert metric.visible_in_plan?(plan)

      put toggle_visible_admin_application_plan_metric_visibility_path(plan, metric)
      assert_response :redirect
      assert_redirected_to edit_admin_application_plan_path(plan)
      refute metric.visible_in_plan?(plan)
    end

    test 'toggle enabled' do
      assert metric.enabled_for_plan?(plan)

      put toggle_enabled_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success
      refute metric.enabled_for_plan?(plan)

      put toggle_enabled_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success
      assert metric.enabled_for_plan?(plan)

      put toggle_enabled_admin_application_plan_metric_visibility_path(plan, metric)
      assert_response :redirect
      assert_redirected_to edit_admin_application_plan_path(plan)
      refute metric.enabled_for_plan?(plan)
    end

    test 'toggle limits only text' do
      assert metric.limits_only_text_in_plan?(plan)

      put toggle_limits_only_text_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success
      refute metric.limits_only_text_in_plan?(plan)

      put toggle_limits_only_text_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success
      assert metric.limits_only_text_in_plan?(plan)

      put toggle_limits_only_text_admin_application_plan_metric_visibility_path(plan, metric)
      assert_response :redirect
      assert_redirected_to edit_admin_application_plan_path(plan)
      refute metric.limits_only_text_in_plan?(plan)
    end
  end

  class ProviderMemberTest < self
    setup do
      @user = FactoryBot.create(:member, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'member missing wrong permission' do
      put toggle_visible_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :forbidden

      put toggle_enabled_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :forbidden

      put toggle_limits_only_text_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :forbidden
    end

    test 'member with right permission and access to all services' do
      user.admin_sections = %w[plans]
      user.save!

      put toggle_visible_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success

      put toggle_enabled_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success

      put toggle_limits_only_text_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
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

      put toggle_visible_admin_application_plan_metric_visibility_path(forbidden_plan, forbidden_metric, format: :js)
      assert_response :not_found

      put toggle_enabled_admin_application_plan_metric_visibility_path(forbidden_plan, forbidden_metric, format: :js)
      assert_response :not_found

      put toggle_limits_only_text_admin_application_plan_metric_visibility_path(forbidden_plan, forbidden_metric, format: :js)
      assert_response :not_found

      put toggle_visible_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success

      put toggle_enabled_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success

      put toggle_limits_only_text_admin_application_plan_metric_visibility_path(plan, metric, format: :js)
      assert_response :success
    end
  end
end
