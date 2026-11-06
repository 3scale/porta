# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Account::ProxyConfigsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    host! provider.external_admin_domain
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

  test '#index loads page IDs before full records with default pagination' do
    skip 'the split query is used only with MySQL' unless System::Database.mysql?

    service = FactoryBot.create(:simple_service, :with_default_backend_api, account: provider)
    FactoryBot.create(:proxy_config, proxy: service.proxy, environment: 'production')
    token = access_token_value(user: provider.admin_user)

    queries = capture_sql_queries do
      get admin_api_account_proxy_configs_path(environment: 'production', access_token: token)
    end

    assert_response :success
    config_queries = queries.grep(/\ASELECT `proxy_configs`\./)
    assert_equal 2, config_queries.size, queries.join("\n")
    assert_match(/\ASELECT `proxy_configs`\.`id` FROM/, config_queries.first)
    assert_match(/\ASELECT `proxy_configs`\.\* FROM/, config_queries.last)
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
    expected = FactoryBot.create_list(:proxy_config, 3, proxy: service.proxy, environment: ProxyConfig::ENVIRONMENTS.first, content: content_hosts('foo.example.com')).last

    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user)
    ), params: {
      per_page: 1,
      page: 1,
      host: 'foo.example.com',
      version: 'latest'
    }

    assert_same_elements [expected.id], response_proxy_config_ids

    get admin_api_account_proxy_configs_path(
      environment: ProxyConfig::ENVIRONMENTS.first,
      access_token: access_token_value(user: provider.admin_user)
    ), params: {
      page: 5,
      host: 'foo.example.com',
      version: 'latest'
    }

    assert_empty response_proxy_config_ids
  end

  test '#index for latest counts matching proxies for pagination' do
    services = FactoryBot.create_list(:simple_service, 3, :with_default_backend_api, account: provider)
    latest_configs = services.map do |service|
      FactoryBot.create_list(:proxy_config, 2, proxy: service.proxy, environment: 'production').last
    end

    queries = capture_sql_queries do
      get admin_api_account_proxy_configs_path(
        environment: 'production', access_token: access_token_value(user: provider.admin_user),
        version: 'latest', per_page: 1, page: 1
      )
    end

    assert_response :success
    assert_equal [latest_configs.first.id], response_proxy_config_ids
    assert_equal({ 'per_page' => 1, 'total_entries' => 3, 'total_pages' => 3, 'current_page' => 1 }, response.parsed_body['metadata'])

    count_queries = queries.grep(/COUNT\(\*\).*FROM ["`]?proxy_configs["`]?/i)
    assert_equal 1, count_queries.size
    assert_match(/\bJOIN\b.*\blatest\b/i, count_queries.first)

    if System::Database.oracle?
      assert_includes count_queries.first, 'NO_MERGE(latest)'
      assert_includes count_queries.first, 'NO_PUSH_PRED(latest)'
    else
      assert_not_includes count_queries.first, 'NO_MERGE(latest)'
      assert_not_includes count_queries.first, 'NO_PUSH_PRED(latest)'
    end
  end

  private

  def content_hosts(*hosts)
    { proxy: { hosts: hosts } }.to_json
  end

  def access_token_value(user:)
    FactoryBot.create(:access_token, owner: user, scopes: %w[account_management]).plaintext_value
  end

  def response_proxy_config_ids
    (JSON.parse(response.body)['proxy_configs'] || []).map { |proxy_config| proxy_config.dig('proxy_config', 'id') }
  end
end
