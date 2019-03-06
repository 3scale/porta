# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Registry::PoliciesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    login! @provider
    rolling_updates_off
    rolling_update(:policy_registry, enabled: true)
  end

  class NoAccessTest < ActionDispatch::IntegrationTest
    test 'access denied' do
      provider = FactoryBot.create(:provider_account)
      login! provider
      rolling_updates_off

      get provider_admin_registry_policies_path
      assert_response :forbidden

      get new_provider_admin_registry_policy_path
      assert_response :forbidden

      post provider_admin_registry_policies_path
      assert_response :forbidden

      policy = FactoryBot.build_stubbed(:policy, account: provider)

      get edit_provider_admin_registry_policy_path(policy.id)
      assert_response :forbidden

      patch provider_admin_registry_policy_path(policy.id)
      assert_response :forbidden
    end

  end

  test '#index' do
    get provider_admin_registry_policies_path
    assert_response :success
  end

  test '#create' do
    get new_provider_admin_registry_policy_path
    assert_response :success

    assert_difference Policy.method(:count) do
      post provider_admin_registry_policies_path, policy_attributes
      assert_response :redirect
    end
  end

  test '#update' do
    policy = FactoryBot.create(:policy, account: @provider)
    config = {type: 'string'}

    get edit_provider_admin_registry_policy_path(policy)
    assert_response :success

    patch provider_admin_registry_policy_path(policy), {description: 'other description', summary: 'other summary', configuration: config.to_json, humanName: 'Foo policy'}
    assert_response :redirect
    policy.reload
    assert_equal config.as_json, policy.schema['configuration']
    assert_equal 'Foo policy', policy.schema['name']
    assert_equal 'other description', policy.schema['description']
    assert_equal 'other summary', policy.schema['summary']
  end

  protected

  def policy_attributes
    attributes = FactoryBot.build(:policy, name: 'my-policy', version: '1.2.0').attributes
    schema = attributes.delete('schema')
    config = schema.delete('configuration').to_json
    attributes['configuration'] = config
    attributes['humanName'] = attributes['name']
    attributes.merge!(schema)
    attributes
  end
end
