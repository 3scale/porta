# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Account::ProxyConfigsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    host! provider.admin_domain
  end

  attr_reader :provider

  test '#index for admin user of one provider for an specific environment' do
    accessible_service1, accessible_service2, deleted_service = FactoryBot.create_list(:simple_service, 3, :with_default_backend_api, account: provider)
    deleted_service.mark_as_deleted!
    active_service_another_provider = FactoryBot.create(:simple_service, :with_default_backend_api, account: FactoryBot.create(:simple_provider))

    [accessible_service1, accessible_service2, deleted_service, active_service_another_provider]
      .product(%w[sandbox production])
      .map do |service, environment|
        FactoryBot.create_list(:proxy_config, 2, proxy: service.proxy, environment: environment)
      end

    %w[sandbox production].each do |environment|
      get admin_api_account_proxy_configs_path(environment: environment, access_token: access_token_value(user: provider.admin_user))

      assert_response :success

      expected_ids = ProxyConfig
                      .joins(:proxy)
                      .where(proxies: { service_id: [accessible_service1, accessible_service2].map(&:id) })
                      .by_environment(environment)
                      .order(:id)
                      .pluck(:id)
      assert_equal expected_ids, response_proxy_config_ids # The order matters for this endpoint bcz it is paginated and we cannot afford random/different/unexpected results for each request
    end
  end

  test '#index for an invalid environment' do
    get admin_api_account_proxy_configs_path(environment:  'invalid', access_token: access_token_value(user: provider.admin_user))

    assert_response :unprocessable_entity
    assert_equal 'invalid environment', JSON.parse(response.body)['error']
  end

  test '#index for member user' do
    services = FactoryBot.create_list(:simple_service, 2, :with_default_backend_api, account: provider)
    services.each { |service| FactoryBot.create_list(:proxy_config, 2, proxy: service.proxy, environment: ProxyConfig::ENVIRONMENTS.first) }

    member = FactoryBot.create(:member, account: provider)

    member.admin_sections = []
    member.save!

    get admin_api_account_proxy_configs_path(environment: ProxyConfig::ENVIRONMENTS.first, access_token: access_token_value(user: member))
    assert_response :forbidden
    assert_empty response_proxy_config_ids

    member.admin_sections = %i[services partners]
    member.member_permission_service_ids = '[]'
    member.save!

    get admin_api_account_proxy_configs_path(environment: ProxyConfig::ENVIRONMENTS.first, access_token: access_token_value(user: member))
    assert_response :success
    assert_empty response_proxy_config_ids

    member.admin_sections = %i[services partners]
    member.member_permission_service_ids = [services[0].id]
    member.save!

    get admin_api_account_proxy_configs_path(environment: ProxyConfig::ENVIRONMENTS.first, access_token: access_token_value(user: member))
    assert_response :success
    assert_equal services[0].proxy.proxy_configs.order(:id).pluck(:id), response_proxy_config_ids
  end

  test '#index accepts pagination params' do
    service = FactoryBot.create(:simple_service, :with_default_backend_api, account: provider)
    FactoryBot.create_list(:proxy_config, 5, proxy: service.proxy, environment: ProxyConfig::ENVIRONMENTS.first)

    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user),
      per_page: 3, page: 2
    )

    assert_response :success

    assert_equal service.proxy.proxy_configs.order(:id).offset(3).limit(3).select(:id).map(&:id), response_proxy_config_ids
  end

  test '#index can be filtered by version' do
    services = FactoryBot.create_list(:simple_service, 2, :with_default_backend_api, account: provider)
    proxy_configs = services.map { |service| FactoryBot.create_list(:proxy_config, 3, proxy: service.proxy, environment: ProxyConfig::ENVIRONMENTS.first) }.flatten



    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user),
      version: proxy_configs.first.version
    )

    assert_response :success
    expected_proxy_config_ids_specific_version = services.map { |service| service.proxy.proxy_configs.where(version: proxy_configs.first.version).select(:id).map(&:id) }.flatten
    assert_same_elements expected_proxy_config_ids_specific_version, response_proxy_config_ids



    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user),
      version: 'latest'
    )

    assert_response :success
    expected_proxy_config_ids_latest_version = services.map { |service| service.proxy.proxy_configs.where(version: proxy_configs.last.version).select(:id).map(&:id) }.flatten
    assert_same_elements expected_proxy_config_ids_latest_version, response_proxy_config_ids
  end

  test '#index with host param: it searches first for latest version of each proxy/service and then filters that result by host (the order of this matters)' do
    service1, service2 = FactoryBot.create_list(:simple_service, 2, :with_default_backend_api, account: provider)

    proxy_config_service1_version1 = FactoryBot.create(:proxy_config, proxy: service1.proxy, environment: ProxyConfig::ENVIRONMENTS.first, content: content_hosts('v1.example.com'))
    proxy_config_service2_version1 = FactoryBot.create(:proxy_config, proxy: service2.proxy, environment: ProxyConfig::ENVIRONMENTS.first, content: content_hosts('v1.example.com'))

    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user)
    ), params: {host: 'v1.example.com', version: 'latest'}

    assert_same_elements [proxy_config_service1_version1.id, proxy_config_service2_version1.id], response_proxy_config_ids


    proxy_config_service2_version2 = FactoryBot.create(:proxy_config, proxy: service2.proxy, environment: ProxyConfig::ENVIRONMENTS.first, content: content_hosts('v2.example.com'))

    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user)
    ), params: {host: 'v1.example.com', version: 'latest'}

    assert_equal [proxy_config_service1_version1.id], response_proxy_config_ids

    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user)
    ), params: {host: 'v2.example.com', version: 'latest'}

    assert_equal [proxy_config_service2_version2.id], response_proxy_config_ids
  end

  test '#index for latest with host param: if the same host is twice, it only returns the latest' do
    service = FactoryBot.create(:simple_service, :with_default_backend_api, account: provider)
    _proxy_config_version_old, proxy_config_version_new = FactoryBot.create_list(:proxy_config, 2, proxy: service.proxy, environment: ProxyConfig::ENVIRONMENTS.first, content: content_hosts('foo.example.com'))

    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user)
    ), params: {host: 'foo.example.com', version: 'latest'}

    assert_equal [proxy_config_version_new.id], response_proxy_config_ids
  end

  test '#index for latest with pagination' do
    service = FactoryBot.create(:simple_service, :with_default_backend_api, account: provider)
    FactoryBot.create_list(:proxy_config, 2, proxy: service.proxy, environment: ProxyConfig::ENVIRONMENTS.first, content: content_hosts('foo.example.com'))

    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user)
    ), params: {
      page: 5,
      host: 'foo.example.com',
      version: 'latest'
    }

    assert_equal [], response_proxy_config_ids
  end

  private

  def content_hosts(*hosts)
    { proxy: { hosts: hosts } }.to_json
  end

  def access_token_value(user:)
    FactoryBot.create(:access_token, owner: user, scopes: %w[account_management]).value
  end

  def response_proxy_config_ids
    (JSON.parse(response.body)['proxy_configs'] || []).map { |proxy_config| proxy_config.dig('proxy_config', 'id') }
  end
end
