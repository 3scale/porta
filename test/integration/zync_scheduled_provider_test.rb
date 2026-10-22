# frozen_string_literal: true

require 'test_helper'

class ZyncScheduledProviderTest < ActionDispatch::IntegrationTest
  disable_transactional_fixtures!

  setup do
    ThreeScale.config.stubs(zync_authentication_token: 'zync-secret')

    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    @service.update!(backend_version: 'oidc')
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    @application = FactoryBot.create(:cinstance, user_account: @buyer,
                                               plan: FactoryBot.create(:application_plan, issuer: @service))
    @client_secret = @application.keys.first
    assert @client_secret.present?
    @token = FactoryBot.create(:access_token, owner: @provider.admin_user,
                                            name: AccessToken::OIDC_SYNC_TOKEN, expires_at: 1.day.from_now.utc.iso8601,
                                            scopes: %w[account_management], permission: 'ro')

    host! @provider.external_admin_domain
    @provider.suspend!
  end

  test 'suspended providers get normal provider and proxy responses on Zync GETs' do
    get admin_api_provider_path(format: :json), params: token_params, headers: zync_headers
    assert_response :success
    assert_equal @provider.external_admin_domain, response.parsed_body.dig('account', 'admin_domain')

    get admin_api_service_proxy_path(@service, format: :json), params: token_params, headers: zync_headers
    assert_response :success
    proxy = response.parsed_body.fetch('proxy')
    assert_equal @service.id, proxy.fetch('service_id')
    assert_equal @service.proxy.endpoint, proxy.fetch('endpoint')
  end

  test 'scheduled providers are forbidden without Zync authentication' do
    @provider.schedule_for_deletion!
    get admin_api_provider_path(format: :json), params: token_params

    assert_response :forbidden
  end

  test 'Zync headers alone do not replace provider authentication' do
    get admin_api_provider_path(format: :json), params: {}, headers: zync_headers
    assert_response :forbidden
  end

  test 'scheduled providers return not found for provider and proxy reads' do
    @provider.schedule_for_deletion!
    get admin_api_provider_path(format: :json), params: token_params, headers: zync_headers
    assert_response :not_found
    assert_empty response.body

    get admin_api_service_proxy_path(@service, format: :json), params: token_params, headers: zync_headers
    assert_response :not_found
    assert_empty response.body
  end

  test 'approved providers return normal data to Zync' do
    @provider.resume!
    get admin_api_provider_path(format: :json), params: token_params, headers: zync_headers

    assert_response :success
    assert_equal @provider.external_admin_domain, response.parsed_body.dig('account', 'admin_domain')
  end

  test 'resuming a scheduled provider restores application data and credentials after not found' do
    path = find_admin_api_applications_path(format: :json)
    params = token_params.merge(application_id: @application.id)
    get path, params: params, headers: zync_headers
    assert_response :success
    original_application = response.parsed_body.fetch('application')
    assert_equal @application.id, original_application.fetch('id')
    assert_equal true, original_application.fetch('enabled')
    assert_equal @application.application_id, original_application.fetch('client_id')
    assert_equal @client_secret, original_application.fetch('client_secret')

    @provider.schedule_for_deletion!
    get path, params: params, headers: zync_headers
    assert_response :not_found
    assert_empty response.body

    @provider.resume!
    get path, params: params, headers: zync_headers
    assert_response :success
    assert_equal original_application, response.parsed_body.fetch('application')
  end

  private

  def zync_headers
    { 'X-Zync-Token' => 'zync-secret' }
  end

  def token_params
    { access_token: @token.plaintext_value }
  end
end
