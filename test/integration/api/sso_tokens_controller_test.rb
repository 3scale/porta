# frozen_string_literal: true

require 'test_helper'

class Admin::Api::SsoTokensControllerTest < ActionDispatch::IntegrationTest
  def setup
    provider = FactoryBot.create(:provider_account)
    @admin = FactoryBot.create(:simple_admin, account: provider, username: 'alaska123')
    @admin.activate!
    @access_token = FactoryBot.create(:access_token, owner: @admin, scopes: 'account_management', permission: 'rw').value

    host! provider.admin_domain
  end

  test 'post create without sso_token params' do
    post admin_api_sso_tokens_path(access_token: @access_token)
    assert_response :bad_request
  end

  test 'successful post create' do
    post admin_api_sso_tokens_path(access_token: @access_token, sso_token: { username: 'alaska123', expires_in: 60 })
    assert_response :success

    # provider key
    post admin_api_sso_tokens_path(provider_key: @admin.account.api_key, sso_token: { username: 'alaska123', expires_in: 60 })
    assert_response :success
  end

  class Admin::Api::SsoTokensControllerForProviderTest < ActionDispatch::IntegrationTest

    disable_transactional_fixtures!

    def setup
      @provider = FactoryBot.create(:provider_account)
      @admin = FactoryBot.create(:simple_admin, account: Account.master)
      @admin.activate!

      @access_token =FactoryBot.create(:access_token, owner: @admin, scopes: 'account_management', permission: 'ro')
      host! @admin.account.admin_domain
    end

    test 'provider_create' do
      FactoryBot.create(:simple_admin, account: @provider, username: ThreeScale.config.impersonation_admin['username'])
      post provider_create_admin_api_sso_tokens_path(format: :json), params: { provider_id: @provider.id, access_token: @access_token.value }
      assert_response :success

      assert sso_token = JSON.parse(response.body)['sso_token']
      assert sso_token.key?('token')
      assert sso_token.key?('sso_url')
    end

    test 'provider_create with expires_in' do
      FactoryBot.create(:simple_admin, account: @provider, username: ThreeScale.config.impersonation_admin['username'])

      Timecop.freeze do
        post provider_create_admin_api_sso_tokens_path(format: :json), params: { provider_id: @provider.id, access_token: @access_token.value, expires_in: 60 }
        assert_response :success

        assert_equal (Time.now.utc + 60).httpdate, response.headers['Expires']
      end
    end
  end
end

