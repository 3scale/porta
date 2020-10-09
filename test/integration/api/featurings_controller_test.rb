# frozen_string_literal: true

require 'test_helper'

class Api::FeaturingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:simple_provider)
    @service = FactoryBot.create(:simple_service, account: provider)
    @plan = FactoryBot.create(:application_plan, issuer: service)
    @plan_feature, @other_feature = FactoryBot.create_list(:feature, 2, featurable: service, scope: plan.class.to_s)

    @plan.features << @plan_feature
    @plan.save!
  end

  attr_reader :provider, :user, :service, :plan, :plan_feature, :other_feature

  class ProviderAdminTest < self
    setup do
      @user = FactoryBot.create(:admin, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'create' do
      post admin_plan_featurings_path(plan), xhr: true, params: create_featuring_params
      assert_response :success
      assert_includes plan.features, other_feature
    end

    test 'destroy' do
      delete admin_plan_featuring_path(plan, plan_feature), xhr: true, params: featuring_params
      assert_response :success
      assert_not_includes plan.features, plan_feature
    end
  end

  class ProviderMemberTest < self
    setup do
      @user = FactoryBot.create(:member, account: provider)
      user.activate!
      login!(provider, user: user)
    end

    test 'member with wrong permission' do
      post admin_plan_featurings_path(plan), xhr: true, params: create_featuring_params
      assert_response :forbidden

      delete admin_plan_featuring_path(plan, plan_feature), xhr: true, params: featuring_params
      assert_response :forbidden
    end

    test 'member with right permission and access to all services' do
      user.admin_sections = %w[plans]
      user.save!

      post admin_plan_featurings_path(plan), xhr: true, params: create_featuring_params
      assert_response :success

      delete admin_plan_featuring_path(plan, plan_feature), xhr: true, params: featuring_params
      assert_response :success
    end

    test 'member with right permission and restricted access to services' do
      forbidden_service = FactoryBot.create(:simple_service, account: provider)
      user.admin_sections = %w[plans]
      user.member_permission_service_ids = [service.id]
      user.save!

      forbidden_service = FactoryBot.create(:simple_service, account: provider)
      forbidden_plan = FactoryBot.create(:application_plan, issuer: forbidden_service)
      forbidden_plan_feature = FactoryBot.create(:feature, featurable: forbidden_service, scope: forbidden_plan.class.to_s)
      forbidden_other_feature = FactoryBot.create(:feature, featurable: forbidden_service)

      post admin_plan_featurings_path(forbidden_plan), xhr: true, params: create_featuring_params.merge(id: forbidden_other_feature.id)
      assert_response :not_found

      delete admin_plan_featuring_path(forbidden_plan, forbidden_plan_feature), xhr: true, params: featuring_params
      assert_response :not_found

      post admin_plan_featurings_path(plan), xhr: true, params: create_featuring_params
      assert_response :success

      delete admin_plan_featuring_path(plan, plan_feature), xhr: true, params: featuring_params
      assert_response :success
    end
  end

  protected

  def featuring_params
    { type: 'application_plan' }
  end

  def create_featuring_params
    featuring_params.merge(id: other_feature.id)
  end
end
