# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AccountFeaturesTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    @user = FactoryBot.create(:admin, account: @provider)
    @token = FactoryBot.create(:access_token, owner: @user, scopes: 'account_management').value

    host! @provider.external_admin_domain
  end

  test 'index with provider_key' do
    FactoryBot.create(:feature, featurable: provider, name: 'Feature 1')
    FactoryBot.create(:feature, featurable: provider, name: 'Feature 2')

    get admin_api_features_path, params: { provider_key: provider.api_key, format: :xml }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_equal 2, xml.xpath('.//features/feature').count
    assert xml.xpath('.//feature/name[text()="Feature 1"]').present?
    assert xml.xpath('.//feature/name[text()="Feature 2"]').present?
  end

  test 'unauthorized without credentials' do
    feature = FactoryBot.create(:feature, featurable: provider)

    get admin_api_feature_path(feature)
    assert_response :forbidden
  end

  test 'index' do
    FactoryBot.create(:feature, featurable: provider, name: 'Feature 1')
    FactoryBot.create(:feature, featurable: provider, name: 'Feature 2')

    get admin_api_features_path, params: { access_token: token, format: :xml }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(response.body)

    assert_equal 2, xml.xpath('.//features/feature').count
    assert xml.xpath('.//feature/name[text()="Feature 1"]').present?
    assert xml.xpath('.//feature/name[text()="Feature 2"]').present?
  end

  test 'show' do
    feature = FactoryBot.create(:feature, featurable: provider, name: 'Test Feature', system_name: 'test_feature')

    get admin_api_feature_path(id: feature.id), params: { access_token: token, format: :xml }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_equal 'Test Feature', xml.xpath('.//feature/name').text
    assert_equal 'test_feature', xml.xpath('.//feature/system_name').text
    assert_equal provider.id.to_s, xml.xpath('.//feature/account_id').text
  end

  test 'show with wrong id' do
    get admin_api_feature_path(id: 0), params: { access_token: token, format: :xml }

    assert_response :not_found
  end

  test 'create' do
    assert_difference 'provider.features.count', 1 do
      post admin_api_features_path, params: {
        access_token: token,
        format: :xml,
        name: 'New Feature',
        system_name: 'new_feature',
        description: 'A new feature'
      }
    end

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_equal 'New Feature', xml.xpath('.//feature/name').text
    assert_equal 'new_feature', xml.xpath('.//feature/system_name').text
    assert_equal 'A new feature', xml.xpath('.//feature/description').text
    assert_equal provider.id.to_s, xml.xpath('.//feature/account_id').text

    feature = provider.features.reload.last
    assert_equal 'New Feature', feature.name
    assert_equal 'new_feature', feature.system_name
    assert_equal 'A new feature', feature.description
  end

  test 'create with minimal params' do
    assert_difference 'provider.features.count', 1 do
      post admin_api_features_path, params: {
        access_token: token,
        format: :xml,
        name: 'Minimal Feature'
      }
    end

    assert_response :success

    feature = provider.features.reload.last
    assert_equal 'Minimal Feature', feature.name
  end

  test 'create with invalid params' do
    assert_no_difference 'provider.features.count' do
      post admin_api_features_path, params: {
        access_token: token,
        format: :xml,
        name: 'x' * 256  # Exceeds max length of 255
      }
    end

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "Name"
  end

  test 'create with duplicate system_name' do
    FactoryBot.create(:feature, featurable: provider, system_name: 'existing_feature')

    assert_no_difference 'provider.features.count' do
      post admin_api_features_path, params: {
        access_token: token,
        format: :xml,
        name: 'Duplicate',
        system_name: 'existing_feature'
      }
    end

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "System name"
  end

  test 'update' do
    feature = FactoryBot.create(:feature, featurable: provider, name: 'Old Name', system_name: 'old_system_name', description: 'Old description')

    put admin_api_feature_path(id: feature.id), params: {
      access_token: token,
      format: :xml,
      name: 'New Name',
      system_name: 'new_system_name',
      description: 'New description'
    }

    assert_response :success

    xml = Nokogiri::XML::Document.parse(@response.body)

    assert_equal 'New Name', xml.xpath('.//feature/name').text
    assert_equal 'new_system_name', xml.xpath('.//feature/system_name').text
    assert_equal 'New description', xml.xpath('.//feature/description').text

    feature.reload
    assert_equal 'New Name', feature.name
    assert_equal 'new_system_name', feature.system_name
    assert_equal 'New description', feature.description
  end

  test 'updating scope is not allowed' do
    feature = FactoryBot.create(:feature, featurable: provider)

    assert_equal 'AccountPlan', feature.scope

    put admin_api_feature_path(id: feature.id), params: {
      access_token: token,
      format: :xml,
      scope: 'ApplicationPlan'
    }

    assert_response :success
    assert_equal 'AccountPlan', feature.reload.scope
  end

  test 'update with wrong id' do
    put admin_api_feature_path(id: 0), params: {
      access_token: token,
      format: :xml,
      name: 'New Name'
    }

    assert_response :not_found
  end

  test 'update with invalid params' do
    feature = FactoryBot.create(:feature, featurable: provider, name: 'Valid Name')

    put admin_api_feature_path(id: feature.id), params: {
      access_token: token,
      format: :xml,
      name: 'x' * 256  # Exceeds max length of 255
    }

    assert_response :unprocessable_entity
    assert_xml_error @response.body, "Name"

    feature.reload
    assert_equal 'Valid Name', feature.name
  end

  test 'destroy' do
    feature = FactoryBot.create(:feature, featurable: provider)

    assert_difference 'provider.features.count', -1 do
      delete admin_api_feature_path(id: feature.id), params: {
        access_token: token,
        format: :xml
      }
    end

    assert_response :success

    assert_empty_xml @response.body

    assert_raise ActiveRecord::RecordNotFound do
      feature.reload
    end
  end

  test 'destroy with wrong id' do
    delete admin_api_feature_path(id: 0), params: {
      access_token: token,
      format: :xml
    }

    assert_response :not_found
  end

  test 'destroy with feature in use' do
    feature = FactoryBot.create(:feature, featurable: provider)
    plan = FactoryBot.create(:account_plan, issuer: provider)
    plan.features << feature

    # Features can be deleted even when in use (no validation prevents this)
    assert_difference 'provider.features.count', -1 do
      delete admin_api_feature_path(id: feature.id), params: {
        access_token: token,
        format: :xml
      }
    end

    assert_response :success
  end

  private

  attr_reader :provider, :user, :token
end
