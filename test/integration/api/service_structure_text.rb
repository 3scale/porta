require 'test_helper'

class Api::ServiceStructureTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryGirl.create(:provider_account)

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_service_show
    service = FactoryGirl.create(:simple_service, account: @provider)

    get admin_service_path(service)
    assert_response :success
    assert assigns['service'].is_a?(Service)
  end

  def test_service_proxy_config_show
    service = FactoryGirl.create(:simple_service, account: @provider)
    config = FactoryGirl.create(:proxy_config, proxy: service.proxy)

    get admin_service_proxy_config_path(id: config.id, service_id: service.id)
    assert_response :success
    assert assigns['service'].is_a?(Service)
  end

  def test_service_applications_index
    service = FactoryGirl.create(:simple_service, account: @provider)

    get admin_service_applications_path(service_id: service.id)
    assert_response :success
    assert assigns['service'].is_a?(Service)
  end
end
