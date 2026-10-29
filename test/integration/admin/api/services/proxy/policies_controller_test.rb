# frozen_string_literal: true

require 'test_helper'

class PoliciesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    host! @provider.external_admin_domain
    @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).plaintext_value
  end

  class PolicyRegistryAccessTokenScopeTest < PoliciesControllerTest
    def setup
      super
      @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[policy_registry]).plaintext_value
    end
  end

  test 'updates policies config when policies_config is a JSON string' do
    config = [
      { name: 'apicast', version: 'builtin', configuration: {}, enabled: true }
    ]

    put admin_api_service_proxy_policies_path(@service, access_token: @access_token, format: :json), params: {
      proxy: { policies_config: config.to_json }
    }, as: :json

    assert_response :success
    assert_equal config.map(&:stringify_keys), @service.reload.proxy.policies_config.as_json
  end

  test 'updates policies config when policies_config is not a JSON string' do
    config = [
      { name: 'apicast', version: 'builtin', configuration: {}, enabled: true }
    ]

    put admin_api_service_proxy_policies_path(@service, access_token: @access_token, format: :json), params: {
      proxy: { policies_config: config }
    }, as: :json

    assert_response :success
    assert_equal config.map(&:stringify_keys), @service.reload.proxy.policies_config.as_json
  end

  test 'updating policies deploys to staging without leaving pending changes' do
    FactoryBot.create(:service_token, service: @service)
    proxy = @service.proxy
    proxy.update_columns(apicast_configuration_driven: true)
    ApicastV2DeploymentService.new(proxy).call(environment: :sandbox)

    config = [
      { name: 'cors', version: 'builtin', configuration: {}, enabled: true },
      { name: 'apicast', version: 'builtin', configuration: {}, enabled: true }
    ]

    assert_difference proxy.proxy_configs.sandbox.method(:count), 1 do
      with_clock_incrementing_on_each_read do
        put admin_api_service_proxy_policies_path(@service, access_token: @access_token, format: :json), params: {
          proxy: { policies_config: config }
        }, as: :json
      end

      assert_response :success
    end

    deployed_config = proxy.proxy_configs.sandbox.newest_first.first!
    deployed_policies = JSON.parse(deployed_config.content).dig('proxy', 'policy_chain')
    assert_equal(%w[cors apicast], deployed_policies.map { |policy| policy.fetch('name') })
    assert_not_predicate proxy.reload, :pending_affecting_changes?
  end

  test 'prints chain level errors' do
    valid_config = { name: 'apicast', configuration: {}, version: 'builtin', enabled: true, removable: false }

    Proxy::PoliciesConfig.stub_const(:MAX_LENGTH, 16.bytes) do
      put admin_api_service_proxy_policies_path(@service, access_token: @access_token, format: :json), params: {
        proxy: { policies_config: valid_config }
      }, as: :json
    end
    resp_body = JSON.parse(response.body)

    assert_response :unprocessable_entity
    assert_equal 'is too long (maximum is 16 characters)', resp_body['errors']['policies_config'][0]
  end

  test 'prints policy level errors' do
    invalid_config = { name: 'apicast', configuration: {}, enabled: true, removable: false }

    put admin_api_service_proxy_policies_path(@service, access_token: @access_token, format: :json), params: {
      proxy: { policies_config: invalid_config}
    }, as: :json
    resp_body = JSON.parse(response.body)

    assert_response :unprocessable_entity
    assert_equal "can't be blank", resp_body['policies_config'][0]['errors']['version'][0]
  end

  test 'policy level errors are promoted to chain errors as well' do
    invalid_config = { name: 'apicast', configuration: {}, enabled: true, removable: false }

    Proxy::PoliciesConfig.stub_const(:MAX_LENGTH, 16.bytes) do
      put admin_api_service_proxy_policies_path(@service, access_token: @access_token, format: :json), params: {
        proxy: { policies_config: invalid_config}
      }, as: :json
    end
    resp_body = JSON.parse(response.body)

    assert_response :unprocessable_entity
    assert_same_elements ['contains some invalid policy', 'is too long (maximum is 16 characters)'], resp_body['errors']['policies_config']
  end
end
