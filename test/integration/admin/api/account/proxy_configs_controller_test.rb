# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Account::ProxyConfigsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    host! provider.admin_domain
  end

  attr_reader :provider

  test '#index for admin user of one provider for an specific environment' do
    accessible_service_1, accessible_service_2, deleted_service = FactoryBot.create_list(:simple_service, 3, :with_default_backend_api, account: provider)
    deleted_service.mark_as_deleted!
    active_service_another_provider = FactoryBot.create(:simple_service, :with_default_backend_api, account: FactoryBot.create(:simple_provider))

    [accessible_service_1, accessible_service_2, deleted_service, active_service_another_provider]
      .product(%w[sandbox production])
      .map do |service, environment|
        FactoryBot.create_list(:proxy_config, 2, proxy: service.proxy, environment: environment)
      end

    %w[sandbox production].each do |environment|
      get admin_api_account_proxy_configs_path(environment: environment, access_token: access_token_value(user: provider.admin_user))

      assert_response :success

      proxy_config_ids = (JSON.parse(response.body)['proxy_configs'] || []).map { |api_doc| api_doc.dig('proxy_config', 'id') }
      expected_ids = ProxyConfig
                      .joins(:proxy)
                      .where(proxies: { service_id: [accessible_service_1, accessible_service_2].map(&:id) })
                      .by_environment(environment)
                      .order(:id)
                      .pluck(:id)
      assert_equal expected_ids, proxy_config_ids # The order matters for this endpoint bcz it is paginated and we cannot afford random/different/unexpected results for each request
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
    proxy_config_ids = (JSON.parse(response.body)['proxy_configs'] || []).map { |api_doc| api_doc.dig('proxy_config', 'id') }
    assert_empty proxy_config_ids

    member.admin_sections = [:services, :partners]
    member.member_permission_service_ids = '[]'
    member.save!

    get admin_api_account_proxy_configs_path(environment: ProxyConfig::ENVIRONMENTS.first, access_token: access_token_value(user: member))
    assert_response :success
    proxy_config_ids = (JSON.parse(response.body)['proxy_configs'] || []).map { |api_doc| api_doc.dig('proxy_config', 'id') }
    assert_empty proxy_config_ids

    member.admin_sections = [:services, :partners]
    member.member_permission_service_ids = [services[0].id]
    member.save!

    get admin_api_account_proxy_configs_path(environment: ProxyConfig::ENVIRONMENTS.first, access_token: access_token_value(user: member))
    assert_response :success
    proxy_config_ids = (JSON.parse(response.body)['proxy_configs'] || []).map { |api_doc| api_doc.dig('proxy_config', 'id') }
    assert_equal services[0].proxy.proxy_configs.order(:id).pluck(:id), proxy_config_ids
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

    proxy_config_ids = (JSON.parse(response.body)['proxy_configs'] || []).map { |api_doc| api_doc.dig('proxy_config', 'id') }
    assert_equal service.proxy.proxy_configs.order(:id).offset(3).limit(3).select(:id).map(&:id), proxy_config_ids
  end

  private

  def access_token_value(user:)
    FactoryBot.create(:access_token, owner: user, scopes: %w[account_management]).value
  end
end
