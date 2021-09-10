require 'test_helper'

class Admin::Api::ObjectsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    @access_token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management])
    @token = @access_token.value

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
    simple_user = FactoryBot.create(:simple_user, account: @provider)
    @access_token.update(owner: simple_user)
    get admin_api_objects_status_path(object_type: 'service', object_id: @service.id, access_token: @token)
    assert_response 403
  end

  # This is to use a test with the provider_key which has no a user logged in
  def test_status_no_current_user
    get admin_api_objects_status_path(object_type: 'service', object_id: @service.id, provider_key: @provider.provider_key)
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
