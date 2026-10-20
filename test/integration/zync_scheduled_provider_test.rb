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
    @provider.schedule_for_deletion!
  end

  %w[oauth oidc].product(%i[json xml], %i[application_id app_id]).each do |backend_version, format, lookup|
    test "#{backend_version} application found by #{lookup} returns normal #{format} data with credentials" do
      @service.update!(backend_version: backend_version)
      value = lookup == :application_id ? @application.id : @application.application_id
      get find_admin_api_applications_path(format: format),
          params: { access_token: @token.plaintext_value, lookup => value }, headers: zync_headers

      assert_response :success
      application = if format == :json
                      response.parsed_body.fetch('application')
                    else
                      Hash.from_xml(response.body).fetch('application')
                    end
      assert_equal @application.id.to_s, application.fetch('id').to_s
      assert_equal @application.application_id, application.fetch('application_id')
      if format == :json
        assert_equal false, application.fetch('enabled')
        assert_equal @application.application_id, application.fetch('client_id')
        assert_equal @client_secret, application.fetch('client_secret')
      else
        assert_equal @client_secret, application.fetch('keys').fetch('key')
      end
    end
  end

  test 'scheduled providers get normal provider and proxy responses on Zync GETs' do
    get admin_api_provider_path(format: :json), params: token_params, headers: zync_headers
    assert_response :success
    assert_equal @provider.external_admin_domain, response.parsed_body.dig('account', 'admin_domain')

    get admin_api_service_proxy_path(@service, format: :xml), params: token_params, headers: zync_headers
    assert_response :success
    proxy = Hash.from_xml(response.body).fetch('proxy')
    assert_equal @service.id.to_s, proxy.fetch('service_id').to_s
    assert_equal @service.proxy.endpoint, proxy.fetch('endpoint')
  end

  test 'OIDC synchronization tokens require an explicit stats scope to read statistics' do
    path = summary_stats_data_services_path(@service, format: :json)
    get path, params: token_params, headers: zync_headers
    assert_response :forbidden

    @token.update!(scopes: %w[stats])
    get path, params: token_params, headers: zync_headers
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test 'missing or invalid Zync headers are forbidden' do
    [{}, { 'X-Zync-Token' => 'incorrect' }].each do |headers|
      get admin_api_provider_path(format: :json), params: token_params, headers: headers
      assert_response :forbidden
    end
  end

  test 'missing Zync server configuration is forbidden' do
    ThreeScale.config.stubs(zync_authentication_token: nil)
    get admin_api_provider_path(format: :json), params: token_params, headers: zync_headers
    assert_response :forbidden
  end

  test 'Zync header requires a valid access token even with a provider key' do
    [{}, { access_token: 'invalid' }, { provider_key: @provider.api_key },
     { provider_key: @provider.api_key, access_token: 'invalid' }].each do |params|
      get admin_api_provider_path(format: :json), params: params, headers: zync_headers
      assert_response :forbidden
    end
  end

  test 'expired access tokens are forbidden even with a provider key' do
    @token.update_columns(expires_at: 1.minute.ago)
    get admin_api_provider_path(format: :json),
        params: token_params.merge(provider_key: @provider.api_key), headers: zync_headers
    assert_response :forbidden
  end

  test 'ordinary access tokens are forbidden with a Zync header even with a provider key' do
    @token.update!(name: 'Personal access token')
    [token_params, token_params.merge(provider_key: @provider.api_key)].each do |params|
      get admin_api_provider_path(format: :json), params: params, headers: zync_headers
      assert_response :forbidden
    end
  end

  test 'foreign provider access tokens are forbidden even with a provider key' do
    other_provider = FactoryBot.create(:provider_account)
    token = FactoryBot.create(:access_token, owner: other_provider.admin_user, name: AccessToken::OIDC_SYNC_TOKEN,
                                            scopes: %w[account_management], permission: 'ro', expires_at: 1.day.from_now.utc.iso8601)
    get admin_api_provider_path(format: :json),
        params: { access_token: token.plaintext_value, provider_key: @provider.api_key }, headers: zync_headers
    assert_response :forbidden
  end

  test 'account management reads require the account management scope' do
    @token.update!(scopes: %w[stats])
    get admin_api_provider_path(format: :json), params: token_params, headers: zync_headers
    assert_response :forbidden
  end

  test 'token owner permissions are enforced' do
    member = FactoryBot.create(:member, account: @provider, member_permission_ids: [])
    @token.update!(owner: member)
    get admin_api_applications_path(format: :json), params: token_params, headers: zync_headers
    assert_response :forbidden
  end

  test 'token owners cannot read applications or proxies of inaccessible services' do
    member = FactoryBot.create(:member, account: @provider, member_permission_ids: [:partners],
                                       member_permission_service_ids: [])
    @token.update!(owner: member)
    get find_admin_api_applications_path(format: :json),
        params: token_params.merge(application_id: @application.id), headers: zync_headers
    assert_response :not_found

    get admin_api_service_proxy_path(@service, format: :json), params: token_params, headers: zync_headers
    assert_response :not_found
  end

  test 'scheduled providers reject Zync requests other than GET' do
    @token.update!(permission: 'rw')
    original_email = @provider.support_email
    head admin_api_provider_path(format: :json), params: token_params, headers: zync_headers
    assert_response :forbidden

    put admin_api_provider_path(format: :json),
        params: token_params.merge(support_email: 'changed@example.com'), headers: zync_headers
    assert_response :forbidden
    assert_equal original_email, @provider.reload.support_email

    original_name = @application.name
    put admin_api_account_application_path(@buyer, @application, format: :json),
        params: token_params.merge(name: 'changed'), headers: zync_headers
    assert_response :forbidden
    assert_equal original_name, @application.reload.name

    delete admin_api_account_application_path(@buyer, @application, format: :json),
           params: token_params, headers: zync_headers
    assert_response :forbidden
    assert Cinstance.exists?(@application.id)

    assert_no_difference 'Cinstance.count' do
      post admin_api_account_applications_path(@buyer, format: :json),
           params: token_params.merge(plan_id: @application.plan_id, name: 'new'), headers: zync_headers
      assert_response :forbidden
    end
  end

  %w[created pending rejected suspended].each do |state|
    test "#{state} providers receive no Zync exception" do
      @provider.update_column(:state, state)
      get admin_api_provider_path(format: :json), params: token_params, headers: zync_headers
      assert_response :forbidden
    end
  end

  test 'approved providers return normal data with and without Zync headers' do
    @provider.resume!
    [AccessToken::OIDC_SYNC_TOKEN, 'Personal access token'].product([{}, zync_headers]).each do |name, headers|
      @token.update!(name: name)
      get admin_api_provider_path(format: :json), params: token_params, headers: headers
      assert_response :success
      assert_equal @provider.external_admin_domain, response.parsed_body.dig('account', 'admin_domain')
    end

    get admin_api_provider_path(format: :json), params: { provider_key: @provider.api_key }
    assert_response :success
    assert_equal @provider.external_admin_domain, response.parsed_body.dig('account', 'admin_domain')
  end

  test 'missing applications and services remain not found' do
    get find_admin_api_applications_path(format: :json),
        params: token_params.merge(application_id: 0), headers: zync_headers
    assert_response :not_found

    get admin_api_service_proxy_path(0, format: :json), params: token_params, headers: zync_headers
    assert_response :not_found
  end

  test 'resuming the provider restores calculated enabled without changing credentials' do
    path = find_admin_api_applications_path(format: :json)
    params = token_params.merge(application_id: @application.id)
    get path, params: params, headers: zync_headers
    assert_response :success
    disabled_application = response.parsed_body.fetch('application')
    assert_equal false, disabled_application.fetch('enabled')

    @provider.resume!
    get path, params: params, headers: zync_headers
    assert_response :success
    assert_equal disabled_application.merge('enabled' => true), response.parsed_body.fetch('application')
  end

  private

  def zync_headers
    { 'X-Zync-Token' => 'zync-secret' }
  end

  def token_params
    { access_token: @token.plaintext_value }
  end
end
