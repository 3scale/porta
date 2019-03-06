# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Registry::PoliciesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.admin_domain
    @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[policy_registry], permission: 'rw')
    ::Logic::RollingUpdates.stubs(enabled?: true)
    ::Account.any_instance.stubs(:provider_can_use?).with(any_parameters).returns(false)
    ::Account.any_instance.stubs(:provider_can_use?).with(:policy_registry).returns(true)
  end

  test 'POST create with valid params persists with those values' do
    assert_difference(@provider.policies.method(:count), 1) do
      post admin_api_registry_policies_path(policy_params)
    end
    assert_response :created
    assert JSON.parse(response.body).dig('policy', 'id')
    policy = @provider.policies.last!
    policy_params[:policy].each { |key, value| assert_equal(value, policy.public_send(key)) }
  end

  test 'POST create responds with an error message when it is incorrect' do
    FactoryBot.create(:policy, policy_params[:policy].merge(account: @provider))
    assert_no_difference(Policy.method(:count)) do
      post admin_api_registry_policies_path(policy_params)
    end
    assert_response :unprocessable_entity
    assert_equal ['has already been taken'], JSON.parse(response.body).dig('errors', 'version')
  end

  test 'POST create returns forbidden when wrong scope' do
    token_admin_with_wrong_scope = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
    assert_no_difference(Policy.method(:count)) do
      post admin_api_registry_policies_path(policy_params(token_admin_with_wrong_scope))
    end
    assert_response :forbidden
  end

  test 'POST create returns forbidden when no permission' do
    member_user = FactoryBot.create(:member, account: @provider)

    token_member_with_right_scope_but_no_permission = FactoryBot.create(:access_token, owner: member_user, scopes: %w[policy_registry]).value
    assert_no_difference(Policy.method(:count)) do
      post admin_api_registry_policies_path(policy_params(token_member_with_right_scope_but_no_permission))
    end
    assert_response :forbidden
  end

  test 'POST create returns forbidden when wrong permission' do
    member_user = FactoryBot.create(:member, account: @provider)
    member_user.member_permissions.create!(admin_section: :partners) # not policy_registry

    token_member_with_wrong_scope = FactoryBot.create(:access_token, owner: member_user, scopes: %w[account_management]).value
    assert_no_difference(Policy.method(:count)) do
      post admin_api_registry_policies_path(policy_params(token_member_with_wrong_scope))
    end
    assert_response :forbidden
  end

  test 'POST create returns created when correct scope and permission' do
    member_user = FactoryBot.create(:member, account: @provider)
    member_user.member_permissions.create!(admin_section: :policy_registry)

    token_member_with_right_scope = FactoryBot.create(:access_token, owner: member_user, scopes: %w[policy_registry]).value
    assert_difference(@provider.policies.method(:count), 1) do
      post admin_api_registry_policies_path(policy_params(token_member_with_right_scope))
    end
    assert_response :created
  end

  test 'POST create when the rolling update "policies" is disabled' do
    ::Account.any_instance.stubs(provider_can_use?: false)
    assert_no_difference(Policy.method(:count)) do
      post admin_api_registry_policies_path(policy_params)
    end
    assert_response :forbidden
  end

  test 'POST create disabled for master' do
    host! master_account.admin_domain
    access_token = FactoryBot.create(:access_token, owner: master_account.admin_users.first!, scopes: %w[policy_registry], permission: 'rw').value
    assert_no_difference(Policy.method(:count)) do
      post admin_api_registry_policies_path(policy_params(access_token))
    end
    assert_response :forbidden
  end

  test 'GET show returns the policy' do
    policy = FactoryBot.create(:policy, account: @provider)
    get admin_api_registry_policy_path(policy, access_token: @access_token.value)
    assert_response :success
    json = JSON.parse(response.body)['policy']
    assert_equal policy.id, json['id']
  end

  test 'GET show finds the policy when name-version is passed as id' do
    policy = FactoryBot.create(:policy, account: @provider, name: 'my_policy', version: '1.0')
    get admin_api_registry_policy_path('my_policy-1.0', access_token: @access_token.value)
    assert_response :success
    json = JSON.parse(response.body)['policy']
    assert_equal policy.id, json['id']
  end

  test 'GET show returns not found when policy does not exist' do
    get admin_api_registry_policy_path(id: 'inexistent-policy', access_token: @access_token.value)
    assert_response :not_found
  end

  test 'format is not part of id' do
    policy = FactoryBot.create(:policy, account: @provider, name: 'my-policy', version: '1.0')

    assert_raises(ActionController::UrlGenerationError) do
      get admin_api_registry_policy_path('my-policy-1.0.json', access_token: @access_token.value)
    end
  end

  test 'GET index returns the policies' do
    FactoryBot.create_list(:policy, 3, account: @provider)
    get admin_api_registry_policies_path(access_token: @access_token.value)
    assert_response :success
    expected_policy_ids = @provider.policies.pluck(:id)
    assert_same_elements expected_policy_ids, JSON.parse(response.body)['policies'].map { |policy| policy.dig('policy', 'id') }
  end

  test 'PUT updates the policy' do
    policy = FactoryBot.create(:policy, account: @provider, version: '1.0')
    new_schema = JSON.parse(file_fixture('policies/apicast-policy.json').read).merge('description': 'New description')
    new_schema['version'] = '1.0'
    put admin_api_registry_policy_path(policy, policy: { schema: new_schema.to_json }, access_token: @access_token.value)
    assert_response :success
    assert_equal 'New description', policy.reload.schema['description']
  end

  test 'PUT updates the policy when name-version is passed as id' do
    policy = FactoryBot.create(:policy, account: @provider, name: 'my_policy', version: '1.0')
    new_schema = JSON.parse(file_fixture('policies/apicast-policy.json').read).merge('description': 'New description')
    new_schema['version'] = '1.0'
    put admin_api_registry_policy_path('my_policy-1.0', policy: { schema: new_schema.to_json }, access_token: @access_token.value)
    assert_response :success
    assert_equal 'New description', policy.reload.schema['description']
  end

  test 'PUT update returns not found when policy does not exist' do
    put admin_api_registry_policy_path(id: 'inexistent-policy', policy: { version: '1.1' }, access_token: @access_token.value)
    assert_response :not_found
  end

  test 'DELETE destroy deletes the policy' do
    policy = FactoryBot.create(:policy, account: @provider)
    delete admin_api_registry_policy_path(policy, access_token: @access_token.value)
    assert_response :success
    assert_empty response.body
  end

  def policy_params(token = @access_token.value)
    @policy_attributes ||= FactoryBot.build(:policy).attributes.symbolize_keys.slice(:name, :version, :schema)
    { policy: @policy_attributes, access_token: token }
  end
end
