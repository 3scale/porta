# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Personal::AccessTokensTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider)
    host! @provider.self_domain
    @admin = FactoryBot.create(:simple_admin, account: @provider)
    @admin_access_token = FactoryBot.create(:access_token, owner: @admin, scopes: %w[account_management])
  end

  class ActionsOnAnAccessToken < Admin::Api::Personal::AccessTokensTest
    def setup
      super
      @access_token_object = FactoryBot.create(:access_token, owner: @admin, scopes: %w[finance])
    end

    test 'access by a non-existent ID or value responds with not_found' do
      perform_request(different_params: {id: 'wrong'})
      assert_response :not_found
    end

    test 'perform request for a token of another user responds with not_found' do
      access_token_object_admin = FactoryBot.create(:access_token, owner: @admin, scopes: %w[finance])
      access_token_another_admin = FactoryBot.create(:access_token, scopes: %w[account_management],
                                                     owner: FactoryBot.create(:admin, account: @provider, admin_sections: [:partners]))

      access_token_object_admin.slice(:id, :value).each_value do |id_or_value|
        perform_request(authentication: {access_token: access_token_another_admin.value}, different_params: {id: id_or_value})
        assert_response :not_found
      end
    end

    test 'perform request by ID works well' do
      perform_request
      assert_it_worked
    end

    test 'perform request by value works well' do
      perform_request(different_params: {id: @access_token_object.value})
      assert_it_worked
    end

    class Admin::Api::Personal::ShowAccessTokenTest < ActionsOnAnAccessToken
      def assert_it_worked
        assert_response :ok
        json_response = JSON.parse(response.body)
        assert_equal @access_token_object.id, json_response.dig('access_token', 'id')
        refute json_response.dig('access_token', 'value')
      end

      def perform_request(authentication: {access_token: @admin_access_token.value}, different_params: {})
        get admin_api_personal_access_token_path({id: @access_token_object.id}.merge(authentication).merge(different_params))
      end
    end

    class Admin::Api::Personal::DeleteAccessTokenTest < ActionsOnAnAccessToken
      def assert_it_worked
        assert_response :ok
        assert_raise(ActiveRecord::RecordNotFound) { @access_token_object.reload }
        assert_empty response.body
      end

      def perform_request(authentication: {access_token: @admin_access_token.value}, different_params: {})
        delete admin_api_personal_access_token_path({id: @access_token_object.id}.merge(authentication).merge(different_params))
      end
    end
  end

  class Admin::Api::Personal::CreateAccessTokenTest < Admin::Api::Personal::AccessTokensTest
    test 'POST creates an access token for the admin user of the access token' do
      assert_difference @admin.access_tokens.method(:count) do
        post admin_api_personal_access_tokens_path({access_token: @admin_access_token.value}), params: access_token_params
        assert_response :created
        assert JSON.parse(response.body).dig('access_token', 'value')
      end
    end

    test 'POST does not accept a custom value' do
      @access_token_params = access_token_params.merge({value: 'foobar'})

      assert_difference @admin.access_tokens.method(:count) do
        perform_request
        assert_response :created
        assert_not_equal 'foobar', JSON.parse(response.body).dig('access_token', 'value')
      end
    end

    test 'POST does not accept a wrong scope' do
      @access_token_params = access_token_params.merge({scopes: %w[wrong]})

      assert_no_difference(AccessToken.method(:count)) do
        perform_request
        assert_response :unprocessable_entity
        assert_equal ['invalid'], JSON.parse(response.body).dig('errors', 'scopes')
      end
    end

    def assert_it_worked
      assert_response :created
      created_token = AccessToken.last
      access_token_params.each do |key, value|
        assert_equal value, created_token.public_send(key)
      end
    end

    def access_token_params(different_params = {})
      @access_token_params ||= { name: 'token name', permission: 'ro', scopes: %w[finance] }.merge(different_params)
    end

    def perform_request(authentication: {access_token: @admin_access_token.value}, different_params: {})
      post admin_api_personal_access_tokens_path(authentication.merge(different_params)), params: access_token_params
    end
  end

  class Admin::Api::Personal::IndexAccessTokenTest < Admin::Api::Personal::AccessTokensTest
    test 'index returns all access tokens of the current user when no param is sent' do
      [@admin, FactoryBot.create(:simple_admin, account: @provider)].each { |owner| FactoryBot.create_list(:access_token, 2, owner: owner) }
      perform_request
      assert_it_worked do |access_tokens_json_response|
        assert_same_elements(@admin.access_tokens.pluck(:id), (access_tokens_json_response.map { |access_token| access_token.dig('access_token', 'id') }))
        assert_empty access_tokens_json_response.map { |access_token| access_token.dig('access_token', 'value') }.compact
      end
    end

    test 'index searches the access tokens of the user containing the name of the param' do
      another_admin = FactoryBot.create(:simple_admin, account: @provider)
      [@admin, another_admin].each do |owner|
        %w[searchable another_name].each { |name| FactoryBot.create_list(:access_token, 2, owner: owner, name: name) }
      end
      perform_request(different_params: {name: 'arch'})
      assert_it_worked do |access_tokens_json_response|
        response_ids = (access_tokens_json_response.map { |access_token| access_token.dig('access_token', 'id') })
        assert_same_elements(@admin.access_tokens.where('name LIKE \'%arch%\'').pluck(:id), response_ids)
      end
    end

    def perform_request(authentication: {access_token: @admin_access_token.value}, different_params: {})
      get admin_api_personal_access_tokens_path(authentication.merge(different_params))
    end

    def assert_it_worked
      assert_response :ok
      assert_instance_of Array, (access_tokens_json_response = JSON.parse(response.body)['access_tokens'])
      yield(access_tokens_json_response) if block_given?
    end
  end

  test 'authenticate with provider_key is forbidden' do
    FactoryBot.create(:cinstance, service: master_account.default_service, user_account: @provider)

    assert_no_difference(AccessToken.method(:count)) do
      perform_request(authentication: {provider_key: @provider.provider_key})
      assert_response :forbidden
    end
  end

  test 'authentication forbidden for member user with the wrong permissions' do
    unauthorized_member = FactoryBot.create(:member, account: @provider, admin_sections: [])
    access_token = FactoryBot.create(:access_token, owner: unauthorized_member, scopes: %w[account_management])

    assert_no_difference(AccessToken.method(:count)) do
      perform_request(authentication: {access_token: access_token.value})
      assert_response :forbidden
    end
  end

  test 'authentication forbidden for member user with the right permissions but wrong access token' do
    authorized_member = FactoryBot.create(:member, account: @provider, admin_sections: [:partners])
    wrong_token_scope = FactoryBot.create(:access_token, owner: authorized_member, scopes: %w[finance])

    assert_no_difference(AccessToken.method(:count)) do
      perform_request(authentication: {access_token: wrong_token_scope.value})
      assert_response :forbidden
    end
  end

  test 'authentication allowed for account_management access token belonging to a member user with the right permissions' do
    authorized_member = FactoryBot.create(:member, account: @provider, admin_sections: [:partners])
    access_token = FactoryBot.create(:access_token, owner: authorized_member, scopes: %w[account_management])
    @access_token_object = FactoryBot.create(:access_token, owner: authorized_member)

    perform_request(authentication: {access_token: access_token.value})
    assert_it_worked
  end

  def self.runnable_methods
    [Admin::Api::Personal::AccessTokensTest, ActionsOnAnAccessToken].include?(self) ? [] : super
  end
end
