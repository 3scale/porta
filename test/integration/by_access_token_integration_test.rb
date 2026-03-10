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
    get admin_api_accounts_path(format: :xml), params: { access_token: @token.plaintext_value }
    assert_response :success

    # token belongs to a different admin domain
    host! provider_2.internal_admin_domain
    get admin_api_accounts_path(format: :xml), params: { access_token: @token.plaintext_value }
    assert_response :forbidden

    host! @provider.external_admin_domain
    # invalid token
    get admin_api_accounts_path(format: :xml), params: { access_token: 'alaska' }
    assert_response :forbidden

    @token.scopes = ['finance']
    @token.save!

    # invalid scope
    get admin_api_accounts_path(format: :xml), params: { access_token: @token.plaintext_value }
    assert_response :forbidden

    @token.scopes = ['account_management']
    @token.save!
    @user.admin_sections = []
    @user.save!

    # user does not have a permission
    get admin_api_accounts_path(format: :xml), params: { access_token: @token.plaintext_value }
    assert_response :forbidden
  end

  test 'validates the scope using HttpBasicAuth' do
    auth_headers = {'Authorization' => "Basic #{Base64.encode64(":#{@token.plaintext_value}")}"}
    get admin_api_registry_policies_path(format: :json), headers: auth_headers
    assert_response :forbidden
  end

  test 'the token has no expiration date' do
    get admin_api_accounts_path(format: :xml), params: { access_token: @token.plaintext_value }

    assert_response :success
  end

  test 'the token has a future expiration date' do
    token = FactoryBot.create(:access_token, owner: @user, scopes: 'account_management', expires_at: 1.day.from_now.utc.iso8601)

    get admin_api_accounts_path(format: :xml), params: { access_token: token.plaintext_value }

    assert_response :success
  end

  test 'the token has a past expiration date' do
    token = FactoryBot.create(:access_token, owner: @user, scopes: 'account_management')
    token.update_columns(expires_at: 1.minute.ago)

    get admin_api_accounts_path(format: :xml), params: { access_token: token.plaintext_value }

    assert_response :forbidden
  end

  test 'authentication with legacy unmigrated token succeeds' do
    token = FactoryBot.create(:access_token, owner: @user, scopes: 'account_management')
    legacy_value = 'legacy_plaintext_token_for_integration'
    token.update_columns(value: legacy_value)

    get admin_api_accounts_path(format: :xml), params: { access_token: legacy_value }

    assert_response :success
    # No migration: DB value remains unchanged
    assert_equal legacy_value, token.reload.read_attribute(:value)
  end

  test 'authentication with leaked database hash fails' do
    token = FactoryBot.create(:access_token, owner: @user, scopes: 'account_management')
    plaintext = token.plaintext_value

    # Verify the token works with plaintext
    get admin_api_accounts_path(format: :xml), params: { access_token: plaintext }
    assert_response :success

    # Get the actual hash stored in the database
    leaked_hash = token.reload.read_attribute(:value)

    # Verify the stored value has our prefix
    assert leaked_hash.start_with?(AccessToken::DIGEST_PREFIX)

    # An attacker trying to use the leaked hash directly should be blocked
    get admin_api_accounts_path(format: :xml), params: { access_token: leaked_hash }

    assert_response :forbidden
  end
end
