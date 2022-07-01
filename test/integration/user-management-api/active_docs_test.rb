# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ActiveDocsTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')

    host! @provider.internal_admin_domain

    @active_doc1 = @provider.api_docs_services.create!(name: 'The Foo API', body: '{"basePath":"http://zebra.example.net", "apis":[]}', published: false)
    @active_doc2 = @provider.api_docs_services.create!(name: 'API FOO 2', body: '{"basePath":"http://zoo.example.net", "apis":[{"foo":"bar"}]}', published: true)
  end

  test 'list active docs as json' do
    get admin_api_active_docs_path(format: :json), params: params
    assert_response :success

    assert_equal [@active_doc1, @active_doc2].extend(::ApiDocs::ServicesRepresenter).to_json, response.body
  end

  test 'list active docs as xml' do
    get admin_api_active_docs_path(format: :xml), params: params
    assert_response :success

    assert_equal [@active_doc1, @active_doc2].extend(::ApiDocs::ServicesRepresenter).to_xml, response.body
  end

  test 'create the json spec' do
    post admin_api_active_docs_path(format: :json), params: params.merge({ api_docs_service: api_docs_service_params })
    assert_response :success

    assert_equal '{"basePath":"https://example.com", "apis":[{"zoo":"pop"}]}', parsed_response['api_doc']['body']
    assert_equal 'test1', parsed_response['api_doc']['description']
    assert_equal 'test', parsed_response['api_doc']['name']
    assert_equal 'test_system_name', parsed_response['api_doc']['system_name']
  end

  test 'create the xml spec' do
    post admin_api_active_docs_path(format: :xml), params: params.merge({ api_docs_service: api_docs_service_params })
    assert_response :success

    assert_equal '{"basePath":"https://example.com", "apis":[{"zoo":"pop"}]}', parsed_response['api_doc']['body']
    assert_equal 'test1', parsed_response['api_doc']['description']
    assert_equal 'test', parsed_response['api_doc']['name']
    assert_equal 'test_system_name', parsed_response['api_doc']['system_name']
  end

  test 'create the json spec without wrap parameters' do
    post admin_api_active_docs_path(format: :json), params: params.merge(api_docs_service_params)
    assert_response :success

    assert_equal '{"basePath":"https://example.com", "apis":[{"zoo":"pop"}]}', parsed_response['api_doc']['body']
    assert_equal 'test1', parsed_response['api_doc']['description']
    assert_equal 'test', parsed_response['api_doc']['name']
    assert_equal 'test_system_name', parsed_response['api_doc']['system_name']
  end

  test 'create the json spec with flat parameters' do
    post admin_api_active_docs_path(format: :json), params: params.merge(api_docs_service_params)
    assert_response :success

    assert_equal '{"basePath":"https://example.com", "apis":[{"zoo":"pop"}]}', parsed_response['api_doc']['body']
    assert_equal 'test1', parsed_response['api_doc']['description']
    assert_equal 'test', parsed_response['api_doc']['name']
    assert_equal 'test_system_name', parsed_response['api_doc']['system_name']
  end

  test 'create the xml spec without system_name' do
    post admin_api_active_docs_path(format: :xml), params: params.merge(api_docs_service_params).except(:system_name)
    assert_response :success

    assert_equal 'test', parsed_response['api_doc']['name']
    assert_equal 'test', parsed_response['api_doc']['system_name']
  end

  test 'update the json spec' do
    assert_equal @provider.api_docs_services.find_by(id: @active_doc1.id).body, '{"basePath":"http://zebra.example.net", "apis":[]}'
    put admin_api_active_doc_path(format: :json, id: @active_doc1.id), params: params.merge(api_docs_service_params)
    assert_response :success

    @active_doc1.reload
    assert_equal '{"basePath":"https://example.com", "apis":[{"zoo":"pop"}]}', @active_doc1.body
    assert_equal 'test', @active_doc1.name
    assert_equal 'the_foo_api', @active_doc1.system_name
  end

  test 'update the xml spec' do
    assert_equal @provider.api_docs_services.find_by(id: @active_doc1.id).body, '{"basePath":"http://zebra.example.net", "apis":[]}'
    put admin_api_active_doc_path(format: :xml, id: @active_doc1.id), params: params.merge(api_docs_service_params)
    assert_response :success

    @active_doc1.reload
    assert_equal '{"basePath":"https://example.com", "apis":[{"zoo":"pop"}]}', @active_doc1.body
    assert_equal 'test', @active_doc1.name
    assert_equal 'the_foo_api', @active_doc1.system_name
  end

  test 'delete the json spec' do
    delete admin_api_active_doc_path(format: :json, id: @active_doc1.id), params: params
    assert_response :success

    assert_raise(ActiveRecord::RecordNotFound) { @active_doc1.reload }
  end

  test 'delete the xml spec' do
    delete admin_api_active_doc_path(format: :xml, id: @active_doc1.id), params: params
    assert_response :success

    assert_raise(ActiveRecord::RecordNotFound) { @active_doc1.reload }
  end

  test 'not valid json body' do
    put admin_api_active_doc_path(format: :json, id: @active_doc2.id), params: params.merge({ body: 'NOT VALID JSON' })
    assert_response :unprocessable_entity

    assert_equal '{"errors":{"body":["Invalid JSON","JSON Spec is invalid"]}}', @response.body
    assert_equal @provider.api_docs_services.find_by(id: @active_doc2.id).body, '{"basePath":"http://zoo.example.net", "apis":[{"foo":"bar"}]}'
  end

  test 'not valid xml body' do
    put admin_api_active_doc_path(format: :xml, id: @active_doc2.id), params: params.merge({ body: 'NOT VALID JSON' })
    assert_response :unprocessable_entity

    assert_equal '<?xml version="1.0" encoding="UTF-8"?><errors><error>Body Invalid JSON</error><error>Body JSON Spec is invalid</error></errors>', @response.body
    assert_equal @provider.api_docs_services.find_by(id: @active_doc2.id).body, '{"basePath":"http://zoo.example.net", "apis":[{"foo":"bar"}]}'
  end

  test 'active id not found behaves properly with json' do
    put admin_api_active_doc_path(format: :json, id: 0), params: params
    assert_response :not_found
    assert_equal @response.body, '{"status":"Not found"}'
    assert_equal @active_doc1.reload.body, '{"basePath":"http://zebra.example.net", "apis":[]}'
    assert_equal @active_doc2.reload.body, '{"basePath":"http://zoo.example.net", "apis":[{"foo":"bar"}]}'
  end

  test 'security wise: active docs is access denied in buyer side' do
    host! @provider.internal_domain
    get admin_api_active_doc_path(format: :json, id: @active_doc1.id), params: params
    assert_response :forbidden
  end

  private

  def parsed_response
    case @response.content_type
    when /xml/ then Hash.from_xml(@response.body)
    when /json/ then JSON.parse(@response.body)
    end
  end

  def api_docs_service_params
    {
      name: 'test',
      system_name: 'test_system_name',
      body: '{"basePath":"https://example.com", "apis":[{"zoo":"pop"}]}',
      description: 'test1'
    }
  end

  def params
    { provider_key: @provider.api_key }
  end
end
