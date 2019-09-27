require 'test_helper'

class Admin::Api::ObjectsControllerTest < ActionDispatch::IntegrationTest

  CONTROLLER = Admin::Api::ObjectsController

  def setup
    @provider = FactoryBot.create(:provider_account)

    host! @provider.admin_domain

    login_provider @provider
  end

  def test_status_404
    get admin_api_objects_status_path(object_type: 'service', object_id: 1)
    assert_response 404
  end

  def test_status_200
    service = FactoryBot.create(:service, account: @provider)
    CONTROLLER::ServiceObject.any_instance.stubs(:authorize).returns(true)
    get admin_api_objects_status_path(object_type: 'service', object_id: service.id)
    assert_response 200
  end

  def test_status_403
    get admin_api_objects_status_path(object_type: 'code-injection', object_id: 1)
    assert_response 403
  end

  def test_status_service
    service = FactoryBot.create(:service, account: @provider)
    CONTROLLER.any_instance.expects(:accessible_services).returns(Service.none)
    get admin_api_objects_status_path(object_type: 'service', object_id: service.id)
    assert_response 403

    CONTROLLER.any_instance.expects(:accessible_services).returns(Service.all)
    get admin_api_objects_status_path(object_type: 'service', object_id: service.id)
    assert_response 200

    service.destroy!
    get admin_api_objects_status_path(object_type: 'service', object_id: service.id)
    assert_response 404
  end

  def test_status_buyer_account
    account = FactoryBot.create(:simple_buyer, provider_account: @provider)
    CONTROLLER.any_instance.expects(:authorize!).raises(CanCan::AccessDenied)
    get admin_api_objects_status_path(object_type: 'buyer_account', object_id: account.id)
    assert_response 403

    CONTROLLER.any_instance.expects(:authorize!).returns(true)
    get admin_api_objects_status_path(object_type: 'buyer_account', object_id: account.id)
    assert_response 200
  end

  def test_status_proxy
    service = FactoryBot.create(:service, account: @provider)
    CONTROLLER.any_instance.expects(:accessible_services).returns(Service.none)
    get admin_api_objects_status_path(object_type: 'proxy', object_id: service.proxy.id)
    assert_response 403

    CONTROLLER.any_instance.expects(:accessible_services).returns(Service.all)
    get admin_api_objects_status_path(object_type: 'proxy', object_id: service.proxy.id)
    assert_response 200
  end

  def test_status_backend_api
    Logic::RollingUpdates.stubs(:enabled?).returns(true)
    backend_api = FactoryBot.create(:backend_api, account: @provider, name: 'API Backend')
    @provider.stubs(:provider_can_use?).with(:api_as_product).returns(false)
    get admin_api_objects_status_path(object_type: 'backend_api', object_id: backend_api.id)
    assert_response 404

    Logic::RollingUpdates.stubs(:enabled?).returns(false)
    get admin_api_objects_status_path(object_type: 'backend_api', object_id: backend_api.id)
    assert_response 200
  end
end
