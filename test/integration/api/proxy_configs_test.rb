require 'test_helper'

class Api::ProxyConfigsTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_index
    service  = FactoryBot.create(:simple_service, account: @provider)
    service.service_tokens.create!(value: 'token')
    p_config = FactoryBot.create(:proxy_config, proxy: service.proxy, environment: 'production')
    s_config = FactoryBot.create(:proxy_config, proxy: service.proxy, environment: 'sandbox')

    get admin_service_proxy_configs_path(service_id: service, environment: 'production')
    assert_equal [p_config.id], assigns['proxy_configs'].map(&:id)

    get admin_service_proxy_configs_path(service_id: service, environment: 'sandbox')
    assert_equal [s_config.id], assigns['proxy_configs'].map(&:id)
  end
end
