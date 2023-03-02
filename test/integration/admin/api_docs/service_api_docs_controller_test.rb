# frozen_string_literal: true

require 'test_helper'

class Admin::ApiDocs::ServiceApiDocsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    @api_docs_service = FactoryBot.create(:api_docs_service, service: @service, account: @service.account)
    login! @provider
  end

  attr_reader :provider, :service, :api_docs_service

  test 'index works under the service scope' do
    other_service = FactoryBot.create(:simple_service, account: provider)
    other_api_docs_service = FactoryBot.create(:api_docs_service, account: provider, service: other_service, name: 'Other spec')

    get admin_service_api_docs_path(service)
    assert_service_active_docs_menus

    page = Nokogiri::HTML4::Document.parse(response.body)
    assert_equal 1, page.xpath(".//table[@class='data']/tbody//tr").count
    assert_match api_docs_service.name, page.xpath(".//table[@class='data']/tbody").text
    assert_not_match other_api_docs_service.name, page.xpath(".//table[@class='data']/tbody").text
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

  test 'member permission' do
    forbidden_service = FactoryBot.create(:simple_service, account: provider)
    forbidden_api_docs_service = FactoryBot.create(:api_docs_service, account: provider, service: forbidden_service)

    member = FactoryBot.create(:member, account: provider, admin_sections: ['plans'])
    member.member_permission_service_ids = [service.id]
    member.activate!

    logout! && login!(provider, user: member)

    get admin_service_api_docs_path(service)
    assert_response :success

    get new_admin_service_api_doc_path(service)
    assert_response :success

    get preview_admin_service_api_doc_path(service, api_docs_service)
    assert_response :success

    get edit_admin_service_api_doc_path(service, api_docs_service)
    assert_response :success

    get admin_service_api_docs_path(forbidden_service)
    assert_response :not_found

    get new_admin_service_api_doc_path(forbidden_service)
    assert_response :not_found

    get preview_admin_service_api_doc_path(forbidden_service, forbidden_api_docs_service)
    assert_response :not_found

    get edit_admin_service_api_doc_path(forbidden_service, forbidden_api_docs_service)
    assert_response :not_found
  end

  test 'member missing right admin section' do
    member = FactoryBot.create(:member, account: provider, admin_sections: ['partners'])
    member.member_permission_service_ids = [service.id]
    member.activate!

    logout! && login!(provider, user: member)

    get admin_service_api_docs_path(service)
    assert_response :forbidden

    get new_admin_service_api_doc_path(service)
    assert_response :forbidden

    get preview_admin_service_api_doc_path(service, api_docs_service)
    assert_response :forbidden

    get edit_admin_service_api_doc_path(service, api_docs_service)
    assert_response :forbidden
  end

  protected

  def assert_service_active_docs_menus
    expected_active_menus = {main_menu: :serviceadmin, submenu: :ActiveDocs}
    assert_equal expected_active_menus, assigns(:active_menus).slice(:main_menu, :submenu)
  end
end
