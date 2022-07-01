require 'test_helper'

class ApiAuthentication::ByProviderKeyIntegrationTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)

    host! @provider.internal_admin_domain
  end

  test 'authenticates using HttpBasicAuth' do
    auth_headers = {'Authorization' => "Basic #{Base64.encode64("#{@provider.provider_key}:")}"}

    get admin_api_services_path(format: :json), headers: auth_headers

    assert_response :ok
  end
end
