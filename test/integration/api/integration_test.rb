require 'test_helper'

class IntegrationsTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)

    login_provider @provider

    host! @provider.admin_domain
  end

  def test_index
    service = FactoryBot.create(:simple_service, account: @provider)

    get admin_service_integration_path(service_id: service)
    assert_response :success
    assert assigns(:show_presenter)
  end

  def test_promote_to_production_error
    service = FactoryBot.create(:simple_service, account: @provider)

    Proxy.any_instance.expects(:deploy_production).returns(true).once
    patch promote_to_production_admin_service_integration_path(service_id: service)
    assert_response :redirect
    assert_not_nil flash[:notice]
    assert_nil flash[:error]
  end

  def test_promote_to_production_success
    service = FactoryBot.create(:simple_service, account: @provider)

    Proxy.any_instance.expects(:deploy_production).returns(false).once
    patch promote_to_production_admin_service_integration_path(service_id: service)
    assert_response :redirect
    assert_nil flash[:notice]
    assert_not_nil flash[:error]
  end

  test 'deploy is called when saving proxy info' do
    Account.any_instance.stubs(:provider_can_use?).returns(false)

    Proxy.any_instance.expects(:save_and_deploy).once

    put "/apiconfig/services/#{@provider.services.first.id}/integration", proxy: {api_backend: '1'}
  end

  test 'deploy is never called when saving proxy info for proxy pro users' do
    rolling_updates_on

    Proxy.any_instance.expects(:save_and_deploy).never
    Proxy.any_instance.expects(:update_attributes).once
    ProxyTestService.expects(:new).never
    ProxyTestService.any_instance.expects(:perform).never

    service = @provider.services.default
    service.update_columns(deployment_option: 'self_managed')
    service.proxy.update_columns(apicast_configuration_driven: false)

    put "/apiconfig/services/#{service.id}/integration", proxy: {api_backend: '1'}
  end

  def test_edit
    rolling_updates_off

    service_id = 'no-such-service'
    get "/apiconfig/services/#{service_id}/integration/edit"
    assert_response :not_found

    service = FactoryBot.create(:simple_service, account: @provider)
    get "/apiconfig/services/#{service.id}/integration/edit"
    assert_response :success
  end
end
