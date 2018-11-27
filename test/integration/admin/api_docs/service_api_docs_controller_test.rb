# frozen_string_literal: true

require 'test_helper'

class Admin::ApiDocs::ServiceApiDocsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryGirl.create(:provider_account)
    @service = @provider.default_service
    @api_docs_service = FactoryGirl.create(:api_docs_service, service: @service, account: @service.account)
    login! @provider
  end

  attr_reader :provider, :service, :api_docs_service

  test 'index works under the service scope' do
    get admin_service_api_docs_path(service)
    assert_service_active_docs_menus
  end

  test 'new works under the service scope' do
    get new_admin_service_api_doc_path(service)
    assert_service_active_docs_menus
  end

  test 'preview works under the service scope' do
    get preview_admin_service_api_doc_path(service, api_docs_service)
    assert_service_active_docs_menus
  end

  test 'edit works under the service scope' do
    get edit_admin_service_api_doc_path(service, api_docs_service)
    assert_service_active_docs_menus
  end

  def assert_service_active_docs_menus
    expected_active_menus = {main_menu: :serviceadmin, submenu: :ActiveDocs}
    assert_equal expected_active_menus, assigns(:active_menus).slice(:main_menu, :submenu)
  end
end
