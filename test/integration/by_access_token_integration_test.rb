# frozen_string_literal: true

require 'test_helper'

class ApiAuthentication::ByAccessTokenIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)

    host! @provider.external_admin_domain

    @user  = FactoryBot.create(:member, account: @provider, admin_sections: %w[partners finance])
    @token = FactoryBot.create(:access_token, owner: @user, scopes: 'account_management')
  end

  def test_index_with_access_token
    provider_2 = FactoryBot.create(:simple_provider)
    # none token
    get admin_api_accounts_path(format: :xml), params: { provider_key: @provider.api_key }
    assert_response :success

    # blank token
    get admin_api_accounts_path(format: :xml), params: { access_token: '' }
    assert_response :forbidden

    # valid token
    get admin_api_accounts_path(format: :xml), params: { access_token: @token.value }
    assert_response :success

    # token belongs to a different admin domain
    host! provider_2.internal_admin_domain
    get admin_api_accounts_path(format: :xml), params: { access_token: @token.value }
    assert_response :forbidden

    host! @provider.external_admin_domain
    # invalid token
    get admin_api_accounts_path(format: :xml), params: { access_token: 'alaska' }
    assert_response :forbidden

    @token.scopes = ['finance']
    @token.save!

    # invalid scope
    get admin_api_accounts_path(format: :xml), params: { access_token: @token.value }
    assert_response :forbidden

    @token.scopes = ['account_management']
    @token.save!
    @user.admin_sections = []
    @user.save!

    # user does not have a permission
    get admin_api_accounts_path(format: :xml), params: { access_token: @token.value }
    assert_response :forbidden
  end

  test 'validates the scope using HttpBasicAuth' do
    auth_headers = {'Authorization' => "Basic #{Base64.encode64(":#{@token.value}")}"}
    get admin_api_registry_policies_path(format: :json), headers: auth_headers
    assert_response :forbidden
  end

  test 'the token has no expiration date' do
      get admin_api_accounts_path(format: :xml), params: { access_token: @token.value }

      assert_response :success
    end

  test 'the token has a future expiration date' do
    token = FactoryBot.create(:access_token, owner: @user, scopes: 'account_management', expires_at: 1.day.from_now.utc.iso8601)

    get admin_api_accounts_path(format: :xml), params: { access_token: token.value }

    assert_response :success
  end

  test 'the token has a past expiration date' do
    token = FactoryBot.create(:access_token, owner: @user, scopes: 'account_management')
    token.update_columns(expires_at: 1.minute.ago)

    get admin_api_accounts_path(format: :xml), params: { access_token: token.value }

    assert_response :forbidden
  end
end
