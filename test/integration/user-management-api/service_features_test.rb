# frozen_string_literal: true

require 'test_helper'

class EnterpriseApiFeaturesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @service = FactoryBot.create(:service, account: @provider)

    host! @provider.external_admin_domain
  end

  # Access token

  test 'show (access_token)' do
    feature = FactoryBot.create(:feature, featurable: @service)
    user    = FactoryBot.create(:member, account: @provider, member_permission_ids: [:partners], member_permission_service_ids: [])
    token   = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    get admin_api_service_feature_path(@service, feature)
    assert_response :forbidden
    get admin_api_service_feature_path(@service, feature), params: { access_token: token.value }
    assert_response :not_found
    user.update(member_permission_service_ids: [@service.id])
    get admin_api_service_feature_path(@service, feature), params: { access_token: token.value }
    assert_response :success
  end

  # Provider key

  test 'index' do
    service = FactoryBot.create(:service, account: @provider)
    FactoryBot.create(:feature, featurable: service)

    get admin_api_service_features_path(service), params: { provider_key: @provider.api_key, format: :xml }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_all_features_available xml, service
  end

  test 'show' do
    feature = FactoryBot.create(:feature, featurable: @service)

    get admin_api_service_feature_path(@service, id: feature.id), params: { provider_key: @provider.api_key, format: :xml }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_a_service_feature xml

    assert_equal xml.xpath('.//feature/service_id').children.first.text, @service.id.to_s
  end

  test 'create' do
    post admin_api_service_features_path(@service), params: { provider_key: @provider.api_key, format: :xml, name: 'example', system_name: 'system_example' }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_a_service_feature xml
    assert_equal xml.xpath('.//feature/name').children.first.to_s, 'example'
    assert_equal xml.xpath('.//feature/system_name').children.first.to_s, 'system_example'
    assert_equal xml.xpath('.//feature/service_id').children.first.to_s, @service.id.to_s
    assert_equal xml.xpath('.//feature/scope').children.first.to_s, 'application_plan'

    feature = @service.features.reload.last
    assert_equal feature.name, 'example'
    assert_equal feature.system_name, 'system_example'
    assert_equal feature.scope, 'ApplicationPlan'
  end

  test 'create with scope == service_account' do
    post admin_api_service_features_path(@service), params: { provider_key: @provider.api_key, format: :xml, scope: 'ServicePlan' }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_a_service_feature xml
    assert_equal xml.xpath('.//feature/scope').children.first.to_s, 'service_plan'

    feature = @service.features.reload.last
    assert_equal feature.scope, 'ServicePlan'
  end

  test 'create with wrong scope' do
    post admin_api_service_features_path(@service), params: { provider_key: @provider.api_key, format: :xml, scope: 'AccountPlan' }

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "Scope"
  end

  pending_test 'create errors xml'
  pending_test 'create features with scope'

  test 'update' do
    feature = FactoryBot.create(:feature, featurable: @service, name: 'old name', system_name: 'old_system_name')

    put admin_api_service_feature_path(@service, id: feature.id), params: { provider_key: @provider.api_key, format: :xml, name: 'new name', system_name: 'new_system_name' }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_a_service_feature xml
    assert_equal xml.xpath('.//feature/name').children.first.to_s, 'new name'
    assert_equal xml.xpath('.//feature/system_name').children.first.to_s, 'new_system_name'

    feature.reload
    assert_equal "new name", feature.name
    assert_equal "new_system_name", feature.system_name
  end

  pending_test 'update with wrong id'
  pending_test 'update errors xml'

  test 'destroy' do
    feature = FactoryBot.create(:feature, featurable: @service)

    delete admin_api_service_feature_path(@service, id: feature.id), params: { provider_key: @provider.api_key, format: :xml, method: '_destroy' }

    assert_response :success

    assert_empty_xml @response.body

    assert_raise ActiveRecord::RecordNotFound do
      feature.reload
    end
  end

  test 'destroy with wrong id' do
    delete admin_api_service_feature_path(@service, id: '0'), params: { provider_key: @provider.api_key, format: :xml, method: '_destroy' }
    assert_response :not_found
  end
end
