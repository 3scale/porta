# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Personal::AccessTokensTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider)
    host! @provider.self_domain
    @admin = FactoryBot.create(:simple_admin, account: @provider)
    @admin_access_token = FactoryBot.create(:access_token, owner: @admin, scopes: %w[account_management])
  end

  attr_reader :provider, :admin, :admin_access_token

  class ActionsOnAnAccessToken < Admin::Api::Personal::AccessTokensTest
    test 'using a non-existent ID or value responds with not_found' do
      perform_request(id: 'wrong', access_token: admin_access_token.value)
      assert_response :not_found
    end

    test 'using another users token responds with not_found' do
      another_admin = FactoryBot.create(:admin, account: provider, admin_sections: [:partners])
      another_admins_token = FactoryBot.create(:access_token, scopes: %w[account_management], owner: another_admin)

      perform_request(id: admin_access_token.id, access_token: another_admins_token.value)
      assert_response :not_found

      perform_request(id: admin_access_token.value, access_token: another_admins_token.value)
      assert_response :not_found
    end

    test 'using the token ID works well' do
      perform_request(id: admin_access_token.id, access_token: admin_access_token.value)
      assert_it_worked
    end

    test 'using the token value works well' do
      perform_request(id: admin_access_token.value, access_token: admin_access_token.value)
      assert_it_worked
    end

    class Admin::Api::Personal::GetAccessTokenTest < ActionsOnAnAccessToken
      def assert_it_worked(access_token = admin_access_token)
        assert_response :ok
        json_response = JSON.parse(response.body)
        assert_equal access_token.id, json_response.dig('access_token', 'id')
        assert_not json_response.dig('access_token', 'value')
      end

      def get_access_token(id:, **query_params)
        get admin_api_personal_access_token_path(id: id, **query_params)
      end

      alias perform_request get_access_token
    end

    class Admin::Api::Personal::DeleteAccessTokenTest < ActionsOnAnAccessToken
      def assert_it_worked(access_token = admin_access_token)
        assert_response :ok
        assert_raise(ActiveRecord::RecordNotFound) { access_token.reload }
        assert_empty response.body
      end

      def delete_access_token(id:, **query_params)
        delete admin_api_personal_access_token_path(id: id, **query_params)
      end

      alias perform_request delete_access_token
    end
  end

  class Admin::Api::Personal::CreateAccessTokenTest < Admin::Api::Personal::AccessTokensTest
    test 'POST creates an access token for the admin user of the access token' do
      assert_difference admin.access_tokens.method(:count) do
        create_access_token(access_token: admin_access_token.value, params: access_token_params)
        assert_response :created
        assert JSON.parse(response.body).dig('access_token', 'value')
      end
    end

    test 'POST does not accept a custom value' do
      value = 'foobar'
      assert_difference @admin.access_tokens.method(:count) do
        create_access_token(access_token: admin_access_token.value, params: access_token_params({ value: value }))
        assert_response :created
        assert_not_equal value, JSON.parse(response.body).dig('access_token', 'value')
      end
    end

    test 'POST does not accept a wrong scope' do
      assert_no_difference(AccessToken.method(:count)) do
        create_access_token(access_token: admin_access_token.value, params: access_token_params({ scopes: %w[wrong] }))
        assert_response :unprocessable_entity
        assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'scopes')
      end
    end

    def assert_it_worked(_access_token = nil)
      assert_response :created
      created_token = AccessToken.last
      access_token_params.each do |key, value|
        assert_equal value, created_token.public_send(key)
      end
    end

    def access_token_params(different_params = {})
      { name: 'token name', permission: 'ro', scopes: %w[finance] }.merge(different_params)
    end

    def create_access_token(params: access_token_params, **query_params)
      post admin_api_personal_access_tokens_path(**query_params), params: params
    end

    alias perform_request create_access_token
  end

  class Admin::Api::Personal::IndexAccessTokenTest < Admin::Api::Personal::AccessTokensTest
    test 'index returns all access tokens of the current user when no param is sent' do
      another_admin = FactoryBot.create(:simple_admin, account: provider)
      [admin, another_admin].each do |owner|
        FactoryBot.create_list(:access_token, 2, owner: owner)
      end

      get_access_tokens
      assert_it_worked do |response_ids|
        assert_same_elements(admin.access_tokens.pluck(:id), response_ids)
      end
    end

    test 'index searches the access tokens of the user containing the name of the param' do
      token1 = FactoryBot.create(:access_token, owner: admin, name: 'Some token')
      token2 = FactoryBot.create(:access_token, owner: admin, name: 'Some OTHER token')

      get_access_tokens(name: 'Some')
      assert_it_worked do |response_ids|
        assert_same_elements [token1, token2].pluck(:id), response_ids
      end

      get_access_tokens(name: 'OTHER')
      assert_it_worked do |response_ids|
        assert_same_elements [token2].pluck(:id), response_ids
      end
    end

    def get_access_tokens(**query_params)
      get admin_api_personal_access_tokens_path(access_token: admin_access_token.value, **query_params)
    end

    alias perform_request get_access_tokens

    def assert_it_worked(_access_token = nil)
      assert_response :ok

      access_tokens = JSON.parse(response.body)['access_tokens']
      assert_instance_of Array, access_tokens
      assert_empty access_tokens.map { |token| token.dig('access_token', 'value') }.compact
      ids = access_tokens.map { |token| token.dig('access_token', 'id') }
      yield(ids) if block_given?
    end
  end

  test 'authenticate with provider_key is forbidden' do
    FactoryBot.create(:cinstance, service: master_account.default_service, user_account: provider)

    assert_no_difference(AccessToken.method(:count)) do
      perform_request(id: admin_access_token.id, access_token: nil, provider_key: provider.provider_key)
      assert_response :forbidden
    end
  end

  test 'authentication forbidden for member user with the wrong permissions' do
    unauthorized_member = FactoryBot.create(:member, account: provider, admin_sections: [])
    unauthorized_access_token = FactoryBot.create(:access_token, owner: unauthorized_member, scopes: %w[account_management])

    assert_no_difference(AccessToken.method(:count)) do
      perform_request(id: 'any', access_token: unauthorized_access_token.value)
      assert_response :forbidden
    end
  end

  test 'authentication forbidden for member user with the right permissions but wrong access token' do
    authorized_member = FactoryBot.create(:member, account: provider, admin_sections: [:partners])
    wrong_token_scope = FactoryBot.create(:access_token, owner: authorized_member, scopes: %w[finance])

    assert_no_difference(AccessToken.method(:count)) do
      perform_request(id: admin_access_token.id, access_token: wrong_token_scope.value)
      assert_response :forbidden
    end
  end

  test 'authentication allowed for account_management access token belonging to a member user with the right permissions' do
    authorized_member = FactoryBot.create(:member, account: provider, admin_sections: [:partners])
    authorized_member_access_token = FactoryBot.create(:access_token, owner: authorized_member, scopes: %w[account_management])
    access_token = FactoryBot.create(:access_token, owner: authorized_member)

    perform_request(id: access_token.id, access_token: authorized_member_access_token.value)
    assert_it_worked(access_token)
  end

  def self.runnable_methods
    [Admin::Api::Personal::AccessTokensTest, ActionsOnAnAccessToken].include?(self) ? [] : super
  end
end
