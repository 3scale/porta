require 'test_helper'

class DeveloperPortal::Admin::Applications::KeysControllerTest < DeveloperPortal::ActionController::TestCase

  def setup
    super
    @provider = FactoryBot.create :provider_account

    @buyer = FactoryBot.create :buyer_account, :provider_account => @provider
    plan  = FactoryBot.create :application_plan, :issuer => @provider.default_service
    @buyer.buy! plan
    @buyer.reload

    @application = @buyer.bought_cinstances.first
    @service = @provider.default_service

    @request.host = @provider.domain
    login_as(@buyer.admins.first)
  end

  test 'provider can deny keys creation with the setting buyers_manage_apps' do
    @service.update_attribute :buyers_manage_apps, false

    post :create, :application_id => @application.id
    assert_response 403
  end

  test 'provider can deny keys creation with the setting buyers_manage_keys' do
    @service.update_attribute :buyers_manage_apps, true
    @service.update_attribute :buyers_manage_keys, false

    post :create, :application_id => @application.id
    assert_response 403
  end

  test 'buyers can create keys' do
    post :create, :application_id => @application.id
    assert_response :redirect

    post :create, :application_id => @application.id, format: :js
    assert_template 'developer_portal/admin/applications/keys/create'
  end

  test 'buyers can destroy keys' do
    @application.application_keys.add(key = 'app-key').save!

    delete :destroy, :application_id => @application.id, id: key
    assert_response :redirect

    @application.application_keys.add(key).save!

    delete :destroy, :application_id => @application.id, id: key, format: :js
    assert_template 'developer_portal/admin/applications/keys/destroy'
  end

  test 'buyers can regenerate keys' do
    @application.application_keys.add(key = 'app-key').save!

    put :regenerate, :application_id => @application.id, id: key
    assert_response :redirect

    @application.application_keys.add(key).save!

    put :regenerate, :application_id => @application.id, id: key, format: :js
    assert_template 'developer_portal/admin/applications/keys/regenerate'
  end
end
