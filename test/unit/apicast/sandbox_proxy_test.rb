require 'test_helper'

class Apicast::SandboxProxyTest < ActiveSupport::TestCase
  def test_proxy_host
    service = FactoryBot.create(:simple_service)
    proxy = Apicast::SandboxProxy.service(service)

    service.proxy.apicast_configuration_driven = false
    service.proxy.sandbox_endpoint = nil

    assert_equal "#{service.system_name}-#{service.account_id}.staging.apicast.io", proxy.proxy_host
  end
end
