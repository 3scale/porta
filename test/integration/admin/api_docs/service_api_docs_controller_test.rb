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

  test 'index renders with the service in sublayout title and in new path' do
    empty_service = FactoryGirl.create(:simple_service, account: provider)
    get admin_service_api_docs_path(empty_service)
    assert_xpath '//*[@id="content"]/h1', 'ActiveDocs' # The title
    assert_xpath "//nav[@class='vertical-nav']//li[contains(@class, 'active')]/a[contains(@href, '#{admin_service_api_docs_path(empty_service)}')]/span", 'ActiveDocs' # The menu
    assert_xpath "//a[contains(@href, '#{new_admin_service_api_doc_path(empty_service)}')]", 'Create your first spec'

    get admin_service_api_docs_path(service)
    assert_xpath '//*[@id="content"]/h1', 'ActiveDocs' # The title
    assert_xpath "//nav[@class='vertical-nav']//li[contains(@class, 'active')]/a[contains(@href, '#{admin_service_api_docs_path(service)}')]/span", 'ActiveDocs' # The menu
    assert_xpath "//a[contains(@href, '#{new_admin_service_api_doc_path(service)}')]", 'Create a new spec'
  end

  test 'index doesn\'t have the API column' do
    get admin_service_api_docs_path(service)
    refute_xpath("//*[@id='content']/table/thead/th[4]", 'API') # Name of the column
    refute_xpath("//*[@id='content']/table/tbody/tr/td[4]", service.name)
  end

  test 'new renders with the service in sublayout title and in without service in the form' do
    get new_admin_service_api_doc_path(service)

    assert_xpath '//*[@id="content"]/h1', 'ActiveDocs' # The title
    assert_xpath "//nav[@class='vertical-nav']//li[contains(@class, 'active')]/a[contains(@href, '#{admin_service_api_docs_path(service)}')]/span", 'ActiveDocs' # The menu
    refute_xpath('//*[@id="api_docs_service_service_id"]') # No selection of service_id in the form
  end

  test 'preview works under the service scope' do
    get preview_admin_service_api_doc_path(service, api_docs_service)
    assert_xpath "//nav[@class='vertical-nav']//li[contains(@class, 'active')]/a[contains(@href, '#{admin_service_api_docs_path(service)}')]/span", 'ActiveDocs' # The menu
    assert_xpath '//*[@id="content"]/h1', 'ActiveDocs' # The title
  end

  test 'edit works under the service scope' do
    get edit_admin_service_api_doc_path(service, api_docs_service)
    assert_xpath "//nav[@class='vertical-nav']//li[contains(@class, 'active')]/a[contains(@href, '#{admin_service_api_docs_path(service)}')]/span", 'ActiveDocs' # The menu
    assert_xpath '//*[@id="content"]/h1', 'ActiveDocs' # The title
    assert_xpath '//*[@id="api_docs_service_service_id"]/option[2]', service.name
  end

  test 'update keeps having service_id selection after failing' do
    put admin_service_api_doc_path service, api_docs_service, {api_docs_service: {body: 'invalid'}}
    assert_xpath '//*[@id="api_docs_service_service_id"]/option[2]', service.name
  end
end
