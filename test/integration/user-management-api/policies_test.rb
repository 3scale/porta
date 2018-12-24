require 'test_helper'

class Admin::Api::PoliciesTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)

    host! @provider.admin_domain
  end

  def test_index_forbidden
    rolling_updates_off
    get(admin_api_policies_path, format: :json, provider_key: @provider.api_key)
    assert_response :not_found
  end

  def test_index
    rolling_updates_on
    ThreeScale.config.sandbox_proxy.stubs(apicast_registry_url: 'https://example.com/policies')
    stub_request(:get, 'https://example.com/policies')
      .to_return(status: 200, body: "{\"policies\":[{\"schema\":\"1\"}]}",
                 headers: { 'Content-Type' => 'application/json' })
    get admin_api_policies_path(format: :json), provider_key: @provider.api_key
    assert_match "[{\"schema\":\"1\"}]", response.body
  end
end
