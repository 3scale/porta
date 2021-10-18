# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Services::Proxy::ConfigsTest < ActionDispatch::IntegrationTest

  def setup
    @account = FactoryBot.create(:provider_account)
    @service = FactoryBot.create(:simple_service, :with_default_backend_api, account: @account)
    @config  = FactoryBot.create(:proxy_config, proxy: @service.proxy, environment: ProxyConfig::ENVIRONMENTS.first)
    @token   = FactoryBot.create(:access_token, owner: @account.admin_user, scopes: 'account_management')

    host! @account.admin_domain
  end

  test 'latest' do
    params = valid_params

    get latest_admin_api_service_proxy_configs_path(params)
    assert_response :success

    headers = {
      'HTTP_IF_MODIFIED_SINCE' => response.header['Last-Modified'],
      'HTTP_IF_NONE_MATCH'     => response.header['ETag']
    }
    get(latest_admin_api_service_proxy_configs_path(params), session: headers)
    assert_response :not_modified

    get latest_admin_api_service_proxy_configs_path(params.merge(format: :xml))
    assert_response :not_acceptable

    params[:environment] = ProxyConfig::ENVIRONMENTS.second
    get latest_admin_api_service_proxy_configs_path(params)
    assert_response :not_found

    params[:environment] = "#{ProxyConfig::ENVIRONMENTS.second}_alaska"
    get latest_admin_api_service_proxy_configs_path(params)
    assert_response :bad_request
  end

  def test_show
    params = valid_params.merge(version: @config.version)

    get admin_api_service_proxy_config_path(params)
    assert_response :success

    headers = {
      'HTTP_IF_MODIFIED_SINCE' => response.header['Last-Modified'],
      'HTTP_IF_NONE_MATCH'     => response.header['ETag']
    }
    get(admin_api_service_proxy_config_path(params), session: headers)
    assert_response :not_modified

    get admin_api_service_proxy_config_path(params.merge(version: 'non-existing-version'))
    assert_response :not_found
  end

  def test_index
    get admin_api_service_proxy_configs_path(valid_params)
    assert_response :success
    assert_equal 1, parsed_response['proxy_configs'].count

    @config.delete
    get admin_api_service_proxy_configs_path(valid_params)
    assert_response :success
    assert_equal 0, parsed_response['proxy_configs'].count
  end

  def test_index_staging
    get admin_api_service_proxy_configs_path(valid_params.merge(environment: 'staging'))
    assert_response :success
    assert_equal 1, parsed_response['proxy_configs'].count
  end

  test 'index by host' do
    get "/admin/api/services/proxy/configs/#{ProxyConfig::ENVIRONMENTS.first}.json?#{host_valid_params.to_query}"
    assert_response :success
    assert_equal 1, parsed_response['proxy_configs'].count
    assert_equal @config.version, parsed_response['proxy_configs'].first['proxy_config']['version']

    new_config = FactoryBot.create(:proxy_config, proxy: @service.proxy, environment: ProxyConfig::ENVIRONMENTS.first)
    get "/admin/api/services/proxy/configs/#{ProxyConfig::ENVIRONMENTS.first}.json?#{host_valid_params.to_query}"
    assert_response :success
    assert_equal 1, parsed_response['proxy_configs'].count
    assert_equal new_config.version, parsed_response['proxy_configs'].first['proxy_config']['version']
  end

  test 'index_by_host only finds the host in the latest version' do
    _proxy_config_old = FactoryBot.create(:proxy_config, proxy: @service.proxy, environment: ProxyConfig::ENVIRONMENTS.first, content: content_hosts('v1.example.com'))
    proxy_config_new  = FactoryBot.create(:proxy_config, proxy: @service.proxy, environment: ProxyConfig::ENVIRONMENTS.first, content: content_hosts('v2.example.com'))

    get admin_api_proxy_configs_path(environment: ProxyConfig::ENVIRONMENTS.first, format: :json), params: { host: 'v1.example.com', access_token: @token.value }
    assert_empty proxy_config_ids

    get admin_api_proxy_configs_path(environment: ProxyConfig::ENVIRONMENTS.first, format: :json), params: { host: 'v2.example.com', access_token: @token.value }
    assert_equal [proxy_config_new.id], proxy_config_ids


    _proxy_config_old, proxy_config_new = FactoryBot.create_list(:proxy_config, 2, proxy: @service.proxy, environment: ProxyConfig::ENVIRONMENTS.first, content: content_hosts('foo.example.com'))

    get admin_api_proxy_configs_path(environment: ProxyConfig::ENVIRONMENTS.first, format: :json), params: { host: 'foo.example.com', access_token: @token.value }
    assert_equal [proxy_config_new.id], proxy_config_ids
  end

  def test_promote
    params = valid_params.merge(version: @config.version, to: 'production')

    assert_difference(ProxyConfig.production.method(:count), +1) do
      post promote_admin_api_service_proxy_config_path(params)
      assert_response :success
    end

    assert_no_difference(ProxyConfig.production.method(:count)) do
      post promote_admin_api_service_proxy_config_path(params.merge(to: 'non-existing-environment'))
      assert_response :unprocessable_entity
    end
  end

  private

  def proxy_config_ids
    (parsed_response['proxy_configs'] || {}).map { |h| h.dig('proxy_config', 'id') }
  end

  def parsed_response
    JSON.parse(response.body)
  end

  def content_hosts(*hosts)
    { proxy: { hosts: hosts } }.to_json
  end

  def host_valid_params
    {
      host:         @config.hosts.first,
      access_token: @token.value,
    }
  end

  def valid_params
    {
      service_id:   @service.id,
      environment:  ProxyConfig::ENVIRONMENTS.first,
      access_token: @token.value,
      format:       :json
    }
  end
end
