require 'test_helper'

class Master::ServiceDiscovery::AuthControllerTest < ActionDispatch::IntegrationTest

  def setup
    @master = master_account
    @callback_url = "/auth/#{ServiceDiscovery}/callback"
  end

  test 'master callback redirects to provider callback' do
    host! @master.admin_domain
    get "#{@callback_url}?self_domain=example.com"
    assert_redirected_to "http://example.com/p/admin#{@callback_url}"
  end
end
