# frozen_string_literal: true

require 'test_helper'

class Admin::ApiDocs::AccountApiDocsControllerTest < ActionDispatch::IntegrationTest

  def setup
    login! current_account
  end

  class ProviderLoggedInTest < Admin::ApiDocs::AccountApiDocsControllerTest
    setup do
      @provider = FactoryGirl.create(:provider_account)
      @service = @provider.default_service
      @api_docs_service = FactoryGirl.create(:api_docs_service, account: @provider, service: nil)
    end

    test 'index gets the api_docs of an account independently of the service' do
      service_2 = FactoryGirl.create(:simple_service, account: provider)
      FactoryGirl.create(:api_docs_service, service: service, account: provider)
      FactoryGirl.create(:api_docs_service, service: service_2, account: provider)

      get admin_api_docs_services_path
      refute_xpath '//*[@id="side-tabs"]' # The service menu
      refute_xpath '//*[@id="tab-content"]/h2[1]', /.* > ActiveDocs/ # The service title

      page = Nokogiri::HTML::Document.parse(response.body)
      api_docs_name_list_nodes = page.xpath("//*[@id='content']/table/tbody/tr/td[1]/a") # From the resulting table, the first column of all api_docs
      actual_api_docs_data = api_docs_name_list_nodes.map { |node| { preview_link: node['href'], api_doc_name: node.text } }
      expected_api_docs_data = provider.api_docs_services.select(:id, :name).map do |api_doc|
        { preview_link: preview_admin_api_docs_service_path(api_doc), api_doc_name: api_doc.name }
      end
      assert_same_elements expected_api_docs_data, actual_api_docs_data
    end

    test 'index has the API column' do
      service_2 = FactoryGirl.create(:simple_service, account: provider)
      FactoryGirl.create(:api_docs_service, service: service, account: provider)
      FactoryGirl.create(:api_docs_service, service: service_2, account: provider)
      get admin_api_docs_services_path

      assert_xpath "//*[@id='content']/table/thead/th[4]", 'API' # Name of the column

      page = Nokogiri::HTML::Document.parse(response.body)
      actual_api_docs_data = page.xpath("//*[@id='content']/table/tbody/tr/td[4]").map(&:text)
      expected_api_docs_data = provider.api_docs_services.includes(:service).pluck(:'services.name').map(&:to_s)
      assert_same_elements expected_api_docs_data, actual_api_docs_data
    end

    test 'new renders without the selector of a service' do
      get new_admin_api_docs_service_path
      assert_xpath '//*[@id="api_docs_service_service_id"]' # The selection of service_id in the form
    end

    test 'preview under the service scope when there is a service' do
      get preview_admin_api_docs_service_path(api_docs_service)
      refute_xpath '//*[@id="side-tabs"]' # The menu
      refute_xpath '//*[@id="tab-content"]/h2[1]', "#{service.name} > ActiveDocs" # The title

      api_docs_service.update({service_id: service.id}, without_protection: true)
      get preview_admin_api_docs_service_path(api_docs_service)
      assert_redirected_to preview_admin_service_api_doc_path(service, api_docs_service)
    end

    test 'edit under the service scope when there is a service' do
      get edit_admin_api_docs_service_path(api_docs_service)
      refute_xpath '//*[@id="side-tabs"]' # The menu
      refute_xpath '//*[@id="tab-content"]/h2[1]', "#{service.name} > ActiveDocs" # The title
      assert_xpath '//*[@id="api_docs_service_service_id"]' # The selection of service_id in the form

      api_docs_service.update({service_id: service.id}, without_protection: true)
      get edit_admin_api_docs_service_path(api_docs_service)
      assert_redirected_to edit_admin_service_api_doc_path(service, api_docs_service)
    end

    test '#create sets all the attributes, including the system_name and the service_id' do
      assert_difference ::ApiDocs::Service.method(:count) do
        post admin_api_docs_services_path(create_params(service_id: service.id, system_name: 'smart_service'))
        assert_response :redirect
      end

      api_docs_service = provider.api_docs_services.last!
      assert_equal 'smart_service', api_docs_service.system_name
      assert_equal service.id, api_docs_service.service_id
      create_params[:api_docs_service].each do |name, value|
        expected_value = %i[published skip_swagger_validations].include?(name) ? (value == '1') : value
        assert_equal expected_value, api_docs_service.public_send(name)
      end
      assert_equal provider.id, api_docs_service.account_id
    end

    test '#update with the right params' do
      put admin_api_docs_service_path update_params(service_id: service.id)
      assert_response :redirect
      assert_equal 'ActiveDocs Spec was successfully updated.', flash[:notice]

      api_docs_service.reload
      update_params[:api_docs_service].each do |name, value|
        expected_value = %i[published skip_swagger_validations].include?(name) ? (value == '1') : value
        assert_equal expected_value, api_docs_service.public_send(name)
      end
      assert_equal provider.id, api_docs_service.account_id
    end

    def test_update_can_remove_service
      api_docs_service.update_attribute(:service_id, provider.default_service_id)

      put admin_api_docs_service_path update_params(service_id: '')
      assert_response :redirect
      assert_equal 'ActiveDocs Spec was successfully updated.', flash[:notice]

      assert_nil api_docs_service.reload.service_id
    end

    def test_system_name_is_not_updated
      old_system_name = api_docs_service.system_name

      put admin_api_docs_service_path update_params(system_name: "#{old_system_name}-2")

      assert_response :redirect
      assert_equal old_system_name, api_docs_service.reload.system_name
    end

    private

    attr_reader :provider, :service, :api_docs_service
    alias current_account provider

  end

  class MasterLoggedInTest < Admin::ApiDocs::AccountApiDocsControllerTest

    test 'Access allowed for master on Saas' do
      get admin_api_docs_services_path
      assert_response :ok

      assert_difference ::ApiDocs::Service.method(:count) do
        post admin_api_docs_services_path(create_params)
        assert_response :redirect
      end

      get admin_api_docs_service_path(id: api_docs_service.id, format: :json)
      assert_response :ok

      get preview_admin_api_docs_service_path(api_docs_service)
      assert_response :ok

      get edit_admin_api_docs_service_path(api_docs_service)
      assert_response :ok

      put toggle_visible_admin_api_docs_service_path(api_docs_service)
      assert_response :redirect
      assert api_docs_service.published?

      put admin_api_docs_service_path(update_params)
      assert_response :redirect
      assert_equal update_params[:api_docs_service][:name], api_docs_service.name

      assert_difference ::ApiDocs::Service.method(:count), -1 do
        delete admin_api_docs_service_path(api_docs_service)
        assert_response :redirect
      end
    end

    test 'Access forbidden for master on-premises' do
      ThreeScale.stubs(master_on_premises?: true)

      get admin_api_docs_services_path
      assert_response :forbidden

      assert_no_difference ::ApiDocs::Service.method(:count) do
        post admin_api_docs_services_path(create_params)
        assert_response :forbidden
      end

      current_account.api_docs_services.create!(create_params[:api_docs_service])

      get admin_api_docs_service_path(id: api_docs_service.id, format: :json)
      assert_response :forbidden

      get preview_admin_api_docs_service_path(api_docs_service)
      assert_response :forbidden

      get edit_admin_api_docs_service_path(api_docs_service)
      assert_response :forbidden

      put toggle_visible_admin_api_docs_service_path(api_docs_service)
      assert_response :forbidden
      refute api_docs_service.published?

      put admin_api_docs_service_path(update_params)
      assert_response :forbidden

      assert_no_difference ::ApiDocs::Service.method(:count) do
        delete admin_api_docs_service_path(api_docs_service)
        assert_response :forbidden
      end
    end

  end

  private

  def create_params(different_params = {})
    @create_params ||= api_docs_params(different_params)
  end

  def update_params(different_params = {})
    @update_params ||= api_docs_params(different_params).merge({id: api_docs_service.id})
  end

  def api_docs_params(different_params = {})
    { api_docs_service: {
      name: 'update_servone', body: '{"apis": [{"foo": "bar"}], "basePath": "http://example.net"}',
      description: 'updated description', published: '0', skip_swagger_validations: '0'
    }.merge(different_params) }
  end

  def api_docs_service
    current_account.api_docs_services.last!
  end

  def current_account
    master_account
  end

end
