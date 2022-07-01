# frozen_string_literal: true

require 'test_helper'

class EnterpriseApiServicePlanFeaturesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @service_plan = FactoryBot.create(:service_plan, issuer: @provider.default_service)
    FactoryBot.create(:feature, featurable: @provider.default_service, scope: 'ServicePlan')

    host! @provider.internal_admin_domain
  end

  test 'index' do
    feat = FactoryBot.create(:feature, featurable: @provider.default_service, scope: 'ServicePlan')
    @service_plan.features << feat
    @service_plan.save!

    get admin_api_service_plan_features_path(@service_plan), params: { provider_key: @provider.api_key, format: :xml }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_all_features_of_plan xml, @service_plan
  end

  test 'not found service_plan replies 404' do
    get admin_api_service_plan_features_path(0), params: { provider_key: @provider.api_key, format: :xml }
    assert_xml_404
  end

  pending_test 'security test on buyer side domain'
  pending_test 'security test on another provider plans' #???

  test 'associate feature to service plan' do
    feat = FactoryBot.create(:feature, featurable: @provider.default_service, scope: 'ServicePlan')
    assert_not @service_plan.features.include?(feat)

    post admin_api_service_plan_features_path(@service_plan), params: { feature_id: feat.id, provider_key: @provider.api_key, format: :xml }

    assert_response :success

    assert @service_plan.features.reload.include?(feat)
  end

  test 'associate feature to service plan twice' do
    already_associated_feat = FactoryBot.create(:feature, featurable: @provider.default_service, scope: 'ServicePlan')
    @service_plan.features << already_associated_feat
    @service_plan.save!

    post admin_api_service_plan_features_path(@service_plan), params: { feature_id: already_associated_feat.id, provider_key: @provider.api_key, format: :xml }
    assert_response :success
  end

  test 'associate feature to service plan of a different service replies 404' do
    other_service = FactoryBot.create(:service)
    assert_not other_service.service_plans.include?(@service_plan)
    feature_not_in_service = FactoryBot.create(:feature, featurable: other_service, scope: 'ServicePlan')

    post admin_api_service_plan_features_path(@service_plan), params: { feature_id: feature_not_in_service.id, provider_key: @provider.api_key, format: :xml }
    assert_xml_404
  end

  test 'associate feature with wrong scope to service plan is denied' do
    wrong_feature = FactoryBot.create(:feature, featurable: @provider.default_service, scope: 'ApplicationPlan')

    post admin_api_service_plan_features_path(@service_plan), params: { feature_id: wrong_feature.id, provider_key: @provider.api_key, format: :xml }

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "Plan type mismatch"
  end

  test 'remove an association of a feature to a service plan' do
    feat = FactoryBot.create(:feature, featurable: @provider.default_service, scope: 'ServicePlan')
    @service_plan.features << feat
    @service_plan.save!

    delete admin_api_service_plan_feature_path(@service_plan, feat), params: { provider_key: @provider.api_key, format: :xml }
    assert_response :success
    assert_not @service_plan.features.reload.include?(feat)

    @service_plan.features << feat
    @service_plan.save!

    delete admin_api_service_plan_feature_path(@service_plan), params: { feature_id: feat.id, provider_key: @provider.api_key, format: :xml }
    assert_response :success
    assert_not @service_plan.features.reload.include?(feat)
  end

  test 'disable non-existing feature' do
    delete admin_api_service_plan_feature_path(@service_plan, id: '0'), params: { provider_key: @provider.api_key, format: :xml }
    assert_response :not_found

    delete admin_api_service_plan_feature_path(@service_plan), params: { feature_id: '0', provider_key: @provider.api_key, format: :xml }
    assert_response :not_found
  end
end
