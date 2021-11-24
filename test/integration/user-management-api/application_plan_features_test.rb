# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApplicationPlanFeaturesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @app_plan = FactoryBot.create(:application_plan, issuer: @provider.default_service)
    FactoryBot.create(:feature, featurable: @provider.default_service)

    host! @provider.admin_domain
  end

  class AccessTokenTest < Admin::Api::ApplicationPlanFeaturesTest
    def setup
      super
      user = FactoryBot.create(:member, account: @provider, admin_sections: %w[partners plans])
      @token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

      User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    end

    test 'index with no token' do
      get admin_api_application_plan_features_path(@app_plan)
      assert_response :forbidden
    end

    test 'index with access to no services' do
      User.any_instance.expects(:member_permission_service_ids).returns([]).at_least_once
      get admin_api_application_plan_features_path(@app_plan), params: params
      assert_response :not_found
    end

    test 'index with access to some service' do
      User.any_instance.expects(:member_permission_service_ids).returns([@provider.default_service.id]).at_least_once
      get admin_api_application_plan_features_path(@app_plan), params: params
      assert_response :success
    end

    test 'index' do
      User.any_instance.stubs(:has_access_to_all_services?).returns(true)
      User.any_instance.expects(:member_permission_service_ids).never
      get admin_api_application_plan_features_path(@app_plan), params: params
      assert_response :success
    end

    private

    def access_token_params(token = @token)
      { access_token: token.value }
    end

    alias params access_token_params
  end

  class ProviderKeyTest < Admin::Api::ApplicationPlanFeaturesTest
    test 'index' do
      feat = FactoryBot.create(:feature, featurable: @provider.default_service)
      @app_plan.features << feat
      @app_plan.save!

      get admin_api_application_plan_features_path(@app_plan, format: :xml), params: params
      assert_response :success

      xml = Nokogiri::XML::Document.parse(@response.body)
      # TODO: optimize this assertions (check users_test e.g.)
      assert_all_features_of_plan xml, @app_plan
    end

    test 'not found application_plan replies 404' do
      get admin_api_application_plan_features_path(0, format: :xml), params: params
      assert_xml_404
    end

    pending_test 'security test on buyer side domain'
    pending_test 'security test on another provider plans'

    test 'enable new feature' do
      feat = FactoryBot.create(:feature, featurable: @provider.default_service)

      post admin_api_application_plan_features_path(@app_plan, format: :xml), params: params.merge({ feature_id: feat.id })
      assert_response :success

      xml = Nokogiri::XML::Document.parse(@response.body)
      assert_equal xml.xpath('.//feature/id').children.first.text, feat.id.to_s
    end

    test 'enabling feature not in service replies 404' do
      feature_not_in_service = FactoryBot.create(:feature, featurable: @provider, scope: "AccountPlan")

      post admin_api_application_plan_features_path(@app_plan, format: :xml), params: params.merge({ feature_id: feature_not_in_service.id })
      assert_xml_404
    end

    test 'enabling feature with wrong scope is denied' do
      wrong_feature = FactoryBot.create(:feature, featurable: @provider.default_service, scope: "ServicePlan")

      post admin_api_application_plan_features_path(@app_plan, format: :xml), params: params.merge({ feature_id: wrong_feature.id })
      assert_response :unprocessable_entity
      assert_xml_error @response.body, "Plan type mismatch"
    end

    pending_test 'enable existing feature'

    test 'disable feature' do
      feat = FactoryBot.create(:feature, featurable: @provider.default_service)

      post admin_api_application_plan_features_path(@app_plan, format: :xml), params: params.merge({ feature_id: feat.id })
      assert_response :success

      xml = Nokogiri::XML::Document.parse(@response.body)
      assert_equal xml.xpath('.//feature/id').children.first.text, feat.id.to_s
    end

    test 'disable non-existing feature' do
      post admin_api_application_plan_features_path(@app_plan, format: :xml), params: params.merge({ feature_id: 'XXX' })
      assert_xml_404
    end

    private

    def provider_key_params
      { provider_key: @provider.api_key }
    end

    alias params provider_key_params
  end
end
