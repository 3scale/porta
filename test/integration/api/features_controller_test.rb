# frozen_string_literal: true

require 'test_helper'

class Api::FeaturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:simple_provider)
    @service = FactoryBot.create(:simple_service, account: provider)
    @plan = FactoryBot.create(:application_plan, issuer: service)
    @feature = FactoryBot.create(:feature, featurable: service, scope: plan.class.to_s)
  end

  attr_reader :provider, :user, :service, :plan, :feature

  class ProviderAdminTest < self
    setup do
      @user = FactoryBot.create(:admin, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'new' do
      get new_admin_plan_feature_path(plan), xhr: true
      assert_response :success
    end

    test 'create' do
      assert_difference(-> { service.features.count }) do
        post admin_plan_features_path(plan), xhr: true, params: create_feature_params
        assert_response :success
      end
    end

    test 'edit' do
      get edit_admin_plan_feature_path(plan, feature), xhr: true, params: { type: 'application_plan' }
      assert_response :success
    end

    test 'update' do
      put admin_plan_feature_path(plan, feature), xhr: true, params: feature_params
      assert_response :success
      assert_equal 'My feature', feature.reload.name
    end

    test 'destroy' do
      delete admin_plan_feature_path(plan, feature), xhr: true
      assert_response :success
      assert_raise(ActiveRecord::RecordNotFound) { feature.reload }
    end
  end

  class ProviderMemberTest < self
    setup do
      @user = FactoryBot.create(:member, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'member with wrong permission' do
      get new_admin_plan_feature_path(plan), xhr: true
      assert_response :forbidden

      get edit_admin_plan_feature_path(plan, feature), xhr: true, params: { type: 'application_plan' }
      assert_response :forbidden

      put admin_plan_feature_path(plan, feature), xhr: true, params: feature_params
      assert_response :forbidden

      delete admin_plan_feature_path(plan, feature), xhr: true
      assert_response :forbidden
    end

    test 'member with right permission and access to all services' do
      user.admin_sections = %w[plans]
      user.save!

      get new_admin_plan_feature_path(plan), xhr: true
      assert_response :success

      get edit_admin_plan_feature_path(plan, feature), xhr: true, params: { type: 'application_plan' }
      assert_response :success

      put admin_plan_feature_path(plan, feature), xhr: true, params: feature_params
      assert_response :success

      delete admin_plan_feature_path(plan, feature), xhr: true
      assert_response :success
    end

    test 'member with right permission and restricted access to services' do
      forbidden_service = FactoryBot.create(:simple_service, account: provider)
      user.admin_sections = %w[plans]
      user.member_permission_service_ids = [service.id]
      user.save!

      forbidden_service = FactoryBot.create(:simple_service, account: provider)
      forbidden_plan = FactoryBot.create(:application_plan, issuer: forbidden_service)
      forbidden_feature = FactoryBot.create(:feature, scope: forbidden_plan.class.to_s, featurable: forbidden_service)

      get new_admin_plan_feature_path(forbidden_plan), xhr: true
      assert_response :not_found

      get edit_admin_plan_feature_path(forbidden_plan, forbidden_feature), xhr: true, params: { type: 'application_plan' }
      assert_response :not_found

      put admin_plan_feature_path(forbidden_plan, forbidden_feature), xhr: true, params: feature_params
      assert_response :not_found

      delete admin_plan_feature_path(forbidden_plan, forbidden_feature), xhr: true
      assert_response :not_found

      get new_admin_plan_feature_path(plan), xhr: true
      assert_response :success

      get edit_admin_plan_feature_path(plan, feature), xhr: true, params: { type: 'application_plan' }
      assert_response :success

      put admin_plan_feature_path(plan, feature), xhr: true, params: feature_params
      assert_response :success

      delete admin_plan_feature_path(plan, feature), xhr: true
      assert_response :success
    end
  end

  protected

  def feature_params
    { feature: { name: 'My feature', description: 'This plan allows you to play with this feature' } }
  end

  def create_feature_params
    feature_params.deep_merge(feature: { system_name: 'my-plan-feature' })
  end
end


