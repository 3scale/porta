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
    model = FactoryBot.build(:policy, version: '1.2.3', name: 'foo')
    policy_attributes = {
      schema: model.schema.to_json,
      directory: model.directory
    }
    assert_difference Policy.method(:count) do
      post provider_admin_registry_policies_path, policy_attributes
      assert_response :redirect
    end
  end

  test '#update' do
    policy = FactoryBot.create(:policy, account: @provider)

    get edit_provider_admin_registry_policy_path(policy)
    assert_response :success

    schema = policy.schema
    schema['configuration']['properties'] = {
      property: {
        description: "A description of your property",
        type: "string"
      }
    }.as_json

    patch provider_admin_registry_policy_path(policy), {schema: schema.to_json}
    assert_response :redirect
    policy.reload
    assert_equal schema, policy.schema
  end
end
