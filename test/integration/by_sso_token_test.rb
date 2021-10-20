# frozen_string_literal: true

require 'test_helper'

class ApiAuthentication::BySsoTokenTest < ActionDispatch::IntegrationTest
  def setup
    @account = FactoryBot.create(:provider_account)
    @master = Account.master
  end

  def test_sso_token
    # apicast mapping service use case
    FactoryBot.create(:active_admin, account: @account, username: ThreeScale.config.impersonation_admin['username'])
    host! Account.master.admin_domain
    post provider_create_admin_api_sso_tokens_path(format: :json), params: { provider_key: @master.api_key, provider_id: @account.id }
    sso_token = JSON.parse(response.body)['sso_token']

    host! @account.admin_domain

    # all good, all fine, life's awesome, i'm making a soup
    params = { host: 'http://example.com', token: sso_token['token'] }
    get admin_api_proxy_configs_path(:production, format: :json, params: params)
    assert_response :success

    # token parameter is missing
    params = { host: 'http://example.com', token: '' }
    get admin_api_proxy_configs_path(:production, format: :json, params: params)
    assert_response :forbidden

    # user not found - token does not exist
    params = { host: 'http://example.com', token: 'alaska' }
    get admin_api_proxy_configs_path(:production, format: :json, params: params)
    assert_response :forbidden
  end
end
