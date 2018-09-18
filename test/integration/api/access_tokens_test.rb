require 'test_helper'

class Admin::Api::AccessTokensTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryGirl.create(:provider_account)
    @admin = FactoryGirl.create(:simple_admin, account: @provider)
    @admin.activate!
    @member = FactoryGirl.create(:simple_user, account: @provider)

    host! @provider.self_domain
  end

  test 'create with access_token' do
    access_token = FactoryGirl.create(:access_token, owner: @admin, scopes: %w(account_management))

    post admin_api_user_access_tokens_path(user_id: @admin.id, access_token: access_token.value, format: :json),
         access_token_params
    assert_response :created, response.body

    post admin_api_user_access_tokens_path(user_id: @member.id, access_token: access_token.value, format: :json),
         access_token_params
    assert_response :forbidden, response.body
  end

  test 'create with provider_key' do
    post admin_api_user_access_tokens_path(user_id: @admin.id, provider_key: @provider.provider_key, format: :json),
         access_token_params
    assert_response :created, response.body

    post admin_api_user_access_tokens_path(user_id: @member.id, provider_key: @provider.provider_key, format: :json),
         access_token_params
    assert_response :created, response.body
  end

  protected

  def access_token_params
    { name: 'token name', permission: 'ro', value: 'foobar', scopes: %w(cms) }
  end
end

