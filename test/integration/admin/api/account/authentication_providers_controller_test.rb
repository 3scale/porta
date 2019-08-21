# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Account::AuthenticationProvidersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.admin_domain
    @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management], permission: 'rw')
  end

  test '#create persists' do
    assert_difference @provider.self_authentication_providers.method(:count) do
      post admin_api_account_authentication_providers_path(authentication_provider_params)
      assert_response :created
      assert JSON.parse(response.body).dig('authentication_provider', 'id').present?
    end
  end

  test '#create saves the attributes' do
    post admin_api_account_authentication_providers_path(authentication_provider_params)
    attributes_params = authentication_provider_params[:authentication_provider]
    authentication_provider = @provider.self_authentication_providers.find_by!(kind: attributes_params[:kind])
    assert_equal AuthenticationProvider.account_types[:provider], authentication_provider.account_type
    assert_equal attributes_params[:client_id], authentication_provider.client_id
    assert_equal attributes_params[:client_secret], authentication_provider.client_secret
    assert_equal attributes_params[:site], authentication_provider.site
    assert_equal attributes_params[:skip_ssl_certificate_verification], authentication_provider.skip_ssl_certificate_verification
    assert_equal attributes_params[:published], authentication_provider.published
  end

  test '#create creates 2 times with the same data' do
    assert_difference @provider.self_authentication_providers.method(:count), 2 do
      2.times do
        post admin_api_account_authentication_providers_path(authentication_provider_params)
        assert_response :created
      end
    end
  end

  test '#create responds with the right error message when the kind is not available' do
    assert_no_difference @provider.self_authentication_providers.method(:count) do
      post admin_api_account_authentication_providers_path(authentication_provider_params(different_attributes: {kind: 'unknown'}))
      assert_response :unprocessable_entity
      assert_equal ["unavailable for this account type"], JSON.parse(response.body).dig('errors', 'kind')
    end
  end

  test '#create requires kind' do
    assert_no_difference @provider.self_authentication_providers.method(:count) do
      post admin_api_account_authentication_providers_path(authentication_provider_params(different_attributes: {kind: ''}))
      assert_equal 'Required parameter missing: kind', response.body
    end
  end

  test '#create keycloak without site returns the right error' do
    post admin_api_account_authentication_providers_path(authentication_provider_params(different_attributes: {kind: 'keycloak', site: ''}))
    assert_equal ['can\'t be blank'], JSON.parse(response.body).dig('errors', 'realm')
  end

  test '#create ensures provider can use provider_sso' do
    Logic::RollingUpdates.stubs(:enabled?).returns(true)
    @provider.stubs(:provider_can_use?).with(:provider_sso).returns(false)
    post admin_api_account_authentication_providers_path(authentication_provider_params)
    assert_response :not_found
  end

  test '#update saves the new attributes values' do
    authentication_provider = create_authentication_provider
    put admin_api_account_authentication_provider_path(authentication_provider, authentication_provider_params)
    assert_response :ok
    attributes_params = authentication_provider_params[:authentication_provider]
    authentication_provider.reload
    assert_equal attributes_params[:client_id], authentication_provider.client_id
    assert_equal attributes_params[:client_secret], authentication_provider.client_secret
    assert_equal attributes_params[:site], authentication_provider.site
    assert_equal attributes_params[:skip_ssl_certificate_verification], authentication_provider.skip_ssl_certificate_verification
    assert_equal attributes_params[:published], authentication_provider.published
  end

  test '#update is forbidden if enforce_sso and already published' do
    authentication_provider = create_authentication_provider
    @provider.settings.update_column(:enforce_sso, true)
    authentication_provider.update_column(:published, true)
    put admin_api_account_authentication_provider_path(authentication_provider, authentication_provider_params)
    assert_response :forbidden
  end

  test '#update ensures provider can use provider_sso' do
    authentication_provider = create_authentication_provider
    Logic::RollingUpdates.stubs(:enabled?).returns(true)
    @provider.stubs(:provider_can_use?).with(:provider_sso).returns(false)
    put admin_api_account_authentication_provider_path(authentication_provider, authentication_provider_params)
    assert_response :not_found
  end

  test '#index returns all the admin portal authentication providers of the current account in json' do
    FactoryBot.create(:auth0_authentication_provider, account: @provider, account_type: AuthenticationProvider.account_types[:provider])
    FactoryBot.create(:keycloak_authentication_provider, account: @provider, account_type: AuthenticationProvider.account_types[:provider])
    FactoryBot.create(:auth0_authentication_provider, account: FactoryBot.build_stubbed(:simple_provider), account_type: AuthenticationProvider.account_types[:provider])
    get admin_api_account_authentication_providers_path(format: :json, access_token: @access_token.value)
    assert_response :ok
    authentication_providers = JSON.parse(response.body)['authentication_providers']
    assert authentication_providers.present?
    assert_equal 2, authentication_providers.length
    2.times do |iteration|
      assert authentication_providers[iteration].dig('authentication_provider', 'callback_url').present?
    end
  end

  test '#index returns all the authentication providers of the current account in xml' do
    FactoryBot.create(:auth0_authentication_provider, account: @provider, account_type: AuthenticationProvider.account_types[:provider])
    FactoryBot.create(:keycloak_authentication_provider, account: @provider, account_type: AuthenticationProvider.account_types[:provider])
    FactoryBot.create(:auth0_authentication_provider, account: FactoryBot.build_stubbed(:simple_provider), account_type: AuthenticationProvider.account_types[:provider])
    get admin_api_account_authentication_providers_path(format: :xml, access_token: @access_token.value)
    assert_response :ok
    assert_xml './authentication_providers/authentication_provider', 2
  end

  test '#index ensures provider can use provider_sso' do
    Logic::RollingUpdates.stubs(:enabled?).returns(true)
    @provider.stubs(:provider_can_use?).with(:provider_sso).returns(false)
    get admin_api_account_authentication_providers_path(format: :json, access_token: @access_token.value)
    assert_response :not_found
  end

  test '#show returns the requested authentication provider' do
    authentication_provider = FactoryBot.create(:self_authentication_provider, account: @provider, account_type: AuthenticationProvider.account_types[:provider])
    get admin_api_account_authentication_provider_path(authentication_provider, format: :json, access_token: @access_token.value)
    assert_response :ok
    assert_equal authentication_provider.id, JSON.parse(response.body).dig('authentication_provider', 'id')
  end

  test '#show ensures provider can use provider_sso' do
    Logic::RollingUpdates.stubs(:enabled?).returns(true)
    @provider.stubs(:provider_can_use?).with(:provider_sso).returns(false)
    authentication_provider = FactoryBot.create(:self_authentication_provider, account: @provider, account_type: AuthenticationProvider.account_types[:provider])
    get admin_api_account_authentication_provider_path(authentication_provider, format: :json, access_token: @access_token.value)
    assert_response :not_found
  end

  private
  
  def create_authentication_provider
    AuthenticationProvider::Auth0.create!(client_id: 'firstClientId', client_secret: 'firstClientSecret',
                                          site: 'http://example.net', account_type: AuthenticationProvider.account_types[:provider], account: @provider)
  end

  def authentication_provider_params(different_attributes: {})
    @authentication_provider_params ||= begin
      attributes = {
        client_id: 'cid', client_secret: 'csecret', site: 'http://example',
        kind: 'auth0', skip_ssl_certificate_verification: true, published: true
      }.merge(different_attributes)
      { authentication_provider: attributes, format: :json, access_token: @access_token.value }
    end
  end
end
