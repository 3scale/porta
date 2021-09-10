require 'test_helper'

class Admin::Api::ObjectsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value

    host! @provider.admin_domain
  end

  def test_status_object_not_found
    get admin_api_objects_status_path(object_type: 'service', object_id: 'abc123', access_token: @token)
    assert_response 404
  end

  def test_status_object_found
    get admin_api_objects_status_path(object_type: 'service', object_id: @service.id, access_token: @token)
    assert_response 200
  end

  def test_status_object_type_not_valid
    get admin_api_objects_status_path(object_type: 'code-injection', object_id: 1, access_token: @token)
    assert_response 403
  end

  def test_status_no_tenant_id
    @service.update_column(:tenant_id, nil)
    get admin_api_objects_status_path(object_type: 'service', object_id: @service.id, access_token: @token)
    assert_response 403
  end

  def test_status_not_admin
    User.any_instance.expects(:admin?).returns(false)
    get admin_api_objects_status_path(object_type: 'service', object_id: @service.id, access_token: @token)
    assert_response 403
  end

  def test_status_no_current_user
    Admin::Api::ObjectsController.any_instance.expects(:current_user).returns(nil)
    get admin_api_objects_status_path(object_type: 'service', object_id: @service.id, access_token: @token)
    assert_response 403
  end

  def test_status_different_tenant
    another_provider = FactoryBot.create(:provider_account)
    get admin_api_objects_status_path(object_type: 'service', object_id: another_provider.default_service.id, access_token: @token)
    assert_response 403

    Account.any_instance.expects(:master?).returns(true)
    get admin_api_objects_status_path(object_type: 'service', object_id: another_provider.default_service.id, access_token: @token)
    assert_response 200
  end
end
