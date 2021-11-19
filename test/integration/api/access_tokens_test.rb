# frozen_string_literal: true

require 'test_helper'

class Admin::Api::AccessTokensTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider, provider_account: master_account)
    @admin = FactoryBot.create(:simple_admin, account: @provider)
    @admin.activate!
    @member = FactoryBot.create(:simple_user, account: @provider)

    host! @provider.self_domain
  end

  test 'create with access_token can not create for another user' do
    access_token = FactoryBot.create(:access_token, owner: @admin, scopes: %w[account_management])

    user_id = @admin.id
    assert_difference(AccessToken.method(:count), 1) do
      post_request(user_id, {access_token: access_token.value})
      assert_response :created, "Not created with response body #{response.body}"
    end
    assert_token_values(user_id)


    assert_no_difference(AccessToken.method(:count)) do
      post_request(@member.id, {access_token: access_token.value})
      assert_response :forbidden, "Not forbidden with response body #{response.body}"
    end
  end

  test 'create does not accept a custom value' do
    access_token = FactoryBot.create(:access_token, owner: @admin, scopes: %w[account_management])

    user_id = @admin.id
    assert_difference(AccessToken.method(:count), 1) do
      post_request(user_id, {access_token: access_token.value}, {value: 'foobar'})
      assert_response :created, "Not created with response body #{response.body}"
    end
    assert_not_equal 'foobar', AccessToken.last!.value
  end

  test 'create does not accept a wrong scope' do
    access_token = FactoryBot.create(:access_token, owner: @admin, scopes: %w[account_management])

    assert_no_difference(AccessToken.method(:count)) do
      post_request(@admin.id, {access_token: access_token.value}, {scopes: ['wrong']})
      assert_response :unprocessable_entity, "Not created with response body #{response.body}"
      assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'scopes')
    end
  end

  test 'create with provider_key can create for any user of that account' do
    FactoryBot.create(:cinstance, service: master_account.default_service, user_account: @provider)

    user_id = @admin.id
    assert_difference(AccessToken.method(:count), 1) do
      post_request(user_id, {provider_key: @provider.provider_key})
      assert_response :created, "Not created with response body #{response.body}"
    end
    assert_token_values(user_id)


    user_id = @member.id
    assert_difference(AccessToken.method(:count), 1) do
      post_request(user_id, {provider_key: @provider.provider_key})
      assert_response :created, "Not created with response body #{response.body}"
    end
    assert_token_values(user_id)
  end

  protected

  def assert_token_values(user_id)
    token = AccessToken.last!
    assert_equal user_id, token.owner_id
    access_token_params.each do |attr_name, attr_value|
      assert_equal token.public_send(attr_name), attr_value
    end
  end

  def post_request(user_id, authentication = {}, different_params = {})
    post admin_api_user_access_tokens_path(authentication.merge({user_id: user_id, format: :json})), params: access_token_params.merge(different_params)
  end

  def access_token_params
    { name: 'token name', permission: 'ro', scopes: %w[cms] }
  end
end
