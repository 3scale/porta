# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AuthenticationProvidersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryGirl.create(:provider_account)
    host! provider.admin_domain
    settings = provider.settings
    settings.allow_branding
    settings.allow_iam_tools
    @access_token = FactoryGirl.create(:access_token, owner: provider.admin_users.first!, scopes: %w[account_management], permission: 'rw')
  end

  test '#create persists' do
    assert_difference provider.authentication_providers.method(:count) do
      post admin_api_authentication_providers_path(authentication_provider_params)
      assert_response :created
      assert JSON.parse(response.body).dig('authentication_provider', 'id').present?
    end
  end

  test '#create saves the attributes' do
    post admin_api_authentication_providers_path(authentication_provider_params(different_attributes: {name: 'Rhsso', system_name: 'rhsso'}))
    attributes_params = authentication_provider_params[:authentication_provider]
    authentication_provider = provider.authentication_providers.find_by!(kind: attributes_params[:kind])
    assert_equal AuthenticationProvider.account_types[:developer], authentication_provider.account_type
    assert_equal 'Rhsso', authentication_provider.name
    assert_equal 'rhsso', authentication_provider.system_name
    assert_equal attributes_params[:client_id], authentication_provider.client_id
    assert_equal attributes_params[:client_secret], authentication_provider.client_secret
    assert_equal attributes_params[:site], authentication_provider.site
    assert_equal attributes_params[:token_url], authentication_provider.token_url
    assert_equal attributes_params[:user_info_url], authentication_provider.user_info_url
    assert_equal attributes_params[:authorize_url], authentication_provider.authorize_url
    assert_equal attributes_params[:skip_ssl_certificate_verification], authentication_provider.skip_ssl_certificate_verification
    assert_equal attributes_params[:automatically_approve_accounts], authentication_provider.automatically_approve_accounts
  end

  test '#create is forbidden without the switches' do
    provider.settings.deny_branding
    assert_no_difference provider.authentication_providers.method(:count) do
      post admin_api_authentication_providers_path(authentication_provider_params)
      assert_response :forbidden
    end
  end

  test '#create requires kind' do
    assert_no_difference provider.authentication_providers.method(:count) do
      post admin_api_authentication_providers_path(authentication_provider_params(different_attributes: {kind: ''}))
      assert_equal 'Required parameter missing: kind', response.body
    end
  end

  test '#create does not create 2 times with the same kind' do
    assert_difference provider.authentication_providers.method(:count) do
      post admin_api_authentication_providers_path(authentication_provider_params)
      assert_response :created
      post admin_api_authentication_providers_path(authentication_provider_params)
      assert_response :unprocessable_entity
      assert_equal ['has already been taken'], JSON.parse(response.body).dig('errors', 'kind')
    end
  end

  test '#create creates a custom authentication provider from a non-existing kind' do
    assert_difference provider.authentication_providers.method(:count) do
      post admin_api_authentication_providers_path(authentication_provider_params(different_attributes: {kind: 'unknown'}))
      assert_response :created
      authentication_provider = provider.authentication_providers.find_by!(kind: 'unknown')
      assert_equal AuthenticationProvider::Custom.name, authentication_provider.type
    end
  end

  test '#create keycloak without site returns the right error' do
    post admin_api_authentication_providers_path(authentication_provider_params(different_attributes: {kind: 'keycloak', site: ''}))
    assert_equal ['can\'t be blank'], JSON.parse(response.body).dig('errors', 'realm')
  end

  test '#update saves the new attributes values' do
    authentication_provider = FactoryGirl.create(:authentication_provider, account: provider)
    put admin_api_authentication_provider_path(authentication_provider, authentication_provider_params(different_attributes: {client_id: 'updated-cid', client_secret: 'updated_client_secret'}))
    assert_response :ok
    attributes_params = authentication_provider_params[:authentication_provider]
    assert_equal attributes_params[:client_id], authentication_provider.reload.client_id
    assert_equal attributes_params[:client_secret], authentication_provider.client_secret
  end

  test '#index returns all the authentication providers of the current account in json' do
    FactoryGirl.create(:redhat_customer_portal_authentication_provider, account: provider)
    FactoryGirl.create(:keycloak_authentication_provider, account: provider)
    FactoryGirl.create(:redhat_customer_portal_authentication_provider, account: FactoryGirl.build_stubbed(:simple_provider))
    get admin_api_authentication_providers_path(format: :json, access_token: access_token.value)
    assert_response :ok
    authentication_providers = JSON.parse(response.body)['authentication_providers']
    assert authentication_providers.present?
    assert_equal 2, authentication_providers.length
    2.times do |iteration|
      assert authentication_providers[iteration].dig('authentication_provider', 'callback_url').present?
    end
  end

  test '#index returns all the authentication providers of the current account in xml' do
    FactoryGirl.create(:redhat_customer_portal_authentication_provider, account: provider)
    FactoryGirl.create(:keycloak_authentication_provider, account: provider)
    FactoryGirl.create(:redhat_customer_portal_authentication_provider, account: FactoryGirl.build_stubbed(:simple_provider))
    get admin_api_authentication_providers_path(format: :xml, access_token: access_token.value)
    assert_response :ok
    assert_xml './authentication_providers/authentication_provider', 2
  end

  test '#show returns the requested authentication provider' do
    authentication_provider = FactoryGirl.create(:authentication_provider, account: provider)
    get admin_api_authentication_provider_path(authentication_provider, format: :json, access_token: access_token.value)
    assert_response :ok
    assert_equal authentication_provider.id, JSON.parse(response.body).dig('authentication_provider', 'id')
  end

  test '#show checks authorization' do
    authentication_provider = FactoryGirl.create(:authentication_provider, account: provider)
    AuthenticationProvider.any_instance.expects(:authorization_scope).with('show').returns('show')
    Ability.any_instance.expects(:authorize!).raises(CanCan::AccessDenied)
    get admin_api_authentication_provider_path(authentication_provider, format: :json, access_token: access_token.value)
    assert_response :forbidden
  end

  private

  attr_reader :provider, :access_token

  def authentication_provider_params(different_attributes: {}, format: :json)
    @authentication_provider_params ||= begin
      attributes = {
        name: 'my-name', system_name: 'system_name', client_id: 'cid', client_secret: 'csecret', site: 'http://site',
        token_url: 'http://token_url', user_info_url: 'http://user_info_url', authorize_url: 'http://authorize_url',
        kind: 'github', skip_ssl_certificate_verification: true, automatically_approve_accounts: true
      }.merge(different_attributes)
      { authentication_provider: attributes, format: format, access_token: access_token.value }
    end
  end
end
