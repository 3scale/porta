# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Personal::AccessTokensTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider)
    host! @provider.self_domain
    @admin = FactoryBot.create(:simple_admin, account: @provider)
    @admin_access_token = FactoryBot.create(:access_token, owner: @admin, scopes: %w[account_management])
  end

  test 'POST creates an access token for the admin user of the access token' do
    assert_difference @admin.access_tokens.method(:count) do
      post admin_api_personal_access_tokens_path({access_token: @admin_access_token.value, format: :json}), access_token_params
      assert_response :created
      assert JSON.parse(response.body).dig('access_token', 'value')
    end
  end

  test 'POST creates an access token for member user with the right permissions and access token' do
    authorized_member = FactoryBot.create(:member, account: @provider, admin_sections: [:partners])
    access_token = FactoryBot.create(:access_token, owner: authorized_member, scopes: %w[account_management])

    assert_difference authorized_member.access_tokens.method(:count) do
      post admin_api_personal_access_tokens_path({access_token: access_token.value, format: :json}), access_token_params
      assert_response :created
    end
  end

  test 'POST does not create an access token for member user with the wrong permissions' do
    unauthorized_member = FactoryBot.create(:member, account: @provider, admin_sections: [])
    access_token = FactoryBot.create(:access_token, owner: unauthorized_member, scopes: %w[account_management])

    assert_no_difference(AccessToken.method(:count)) do
      post admin_api_personal_access_tokens_path({access_token: access_token.value, format: :json}), access_token_params
      assert_response :forbidden
    end
  end

  test 'POST does not create an access token for member user with the right permissions but wrong access token' do
    authorized_member = FactoryBot.create(:member, account: @provider, admin_sections: [:partners])
    wrong_token_scope = FactoryBot.create(:access_token, owner: authorized_member, scopes: %w[finance])

    assert_no_difference(AccessToken.method(:count)) do
      post admin_api_personal_access_tokens_path({access_token: wrong_token_scope.value, format: :json}), access_token_params
      assert_response :forbidden
    end
  end

  test 'POST does not accept a custom value' do
    assert_difference @admin.access_tokens.method(:count) do
      post admin_api_personal_access_tokens_path({access_token: @admin_access_token.value, format: :json}), access_token_params({value: 'foobar'})
      assert_response :created
      assert_not_equal 'foobar', JSON.parse(response.body).dig('access_token', 'value')
    end
  end

  test 'POST does not accept a wrong scope' do
    assert_no_difference(AccessToken.method(:count)) do
      post admin_api_personal_access_tokens_path({access_token: @admin_access_token.value, format: :json}), access_token_params({scopes: %w[wrong]})
      assert_response :unprocessable_entity
      assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'scopes')
    end
  end

  test 'POST create with provider_key is forbidden' do
    FactoryBot.create(:cinstance, service: master_account.default_service, user_account: @provider)

    assert_no_difference(AccessToken.method(:count)) do
      post admin_api_personal_access_tokens_path({provider_key: @provider.provider_key, format: :json}), access_token_params
      assert_response :forbidden
    end
  end

  private

  def access_token_params(different_params = {})
    { name: 'token name', permission: 'ro', scopes: %w[finance] }.merge(different_params)
  end

  # TODO:
  # documentation... api docs
  # mark the previous api as deprecated
end
