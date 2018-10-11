# frozen_string_literal: true

require 'test_helper'

class Admin::ApiDocs::ServiceApiDocsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryGirl.create(:provider_account)
    @service = @provider.default_service
    @api_docs_service = @provider.api_docs_services.create!(api_docs_params, without_protection: true)
    login! @provider
  end

  attr_reader :provider, :service, :api_docs_service

  test 'index renders with the service in sublayout title and in new path' do
    empty_service = FactoryGirl.create(:simple_service, account: provider)
    get admin_service_api_docs_path(empty_service)
    assert_xpath '//*[@id="tab-content"]/h2[1]', "#{empty_service.name} > ActiveDocs"
    assert_xpath '//*[@id="side-tabs"]' # The menu
    assert_xpath "//a[contains(@href, '#{new_admin_service_api_doc_path(empty_service)}')]", 'Create your first spec'

    get admin_service_api_docs_path(service)
    assert_xpath '//*[@id="tab-content"]/h2[1]', "#{service.name} > ActiveDocs"
    assert_xpath '//*[@id="side-tabs"]' # The menu
    assert_xpath "//a[contains(@href, '#{new_admin_service_api_doc_path(service)}')]", 'Create a new spec'
  end

  test 'new renders with the service in sublayout title and in selected service' do
    get new_admin_service_api_doc_path(service)

    assert_xpath '//*[@id="tab-content"]/h2[1]', "#{service.name} > ActiveDocs"
    assert_xpath '//*[@id="side-tabs"]' # The menu

    page = Nokogiri::HTML::Document.parse(response.body)
    page_option = page.xpath('//*[@id="api_docs_service_service_id"]/option[2]')[0] # The option[1] is the empty service
    assert_equal service.name, page_option.text
    assert_equal service.id.to_s, page_option['value']
    assert_equal 'selected', page_option['selected']
  end

  test 'preview works under the service scope' do
    get preview_admin_service_api_doc_path(service, api_docs_service)
    assert_xpath '//*[@id="side-tabs"]' # The menu
    assert_xpath '//*[@id="tab-content"]/h2[1]', "#{service.name} > ActiveDocs" # The title
  end

  test 'edit works under the service scope' do
    get edit_admin_service_api_doc_path(service, api_docs_service)
    assert_xpath '//*[@id="side-tabs"]' # The menu
    assert_xpath '//*[@id="tab-content"]/h2[1]', "#{service.name} > ActiveDocs" # The title
  end

  private

  def api_docs_params
    {name: 'foo', body: '{"basePath": "http://foo.example.com", "apis":[{"foo": "bar"}]}', service: service}
  end
end
