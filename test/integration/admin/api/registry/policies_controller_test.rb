# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Registry::PoliciesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.admin_domain
    @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management], permission: 'rw')
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

  def policy_params
    { policy: {name: 'my-name', version: 'my-version', schema: '{"foo": "bar"}'}, access_token: @access_token.value }
  end
end
