# frozen_string_literal: true

require 'test_helper'

class PoliciesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    host! @provider.external_admin_domain
    @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
  end

  class PolicyRegistryAccessTokenScopeTest < PoliciesControllerTest
    def setup
      super
      @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[policy_registry]).value
    end
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
