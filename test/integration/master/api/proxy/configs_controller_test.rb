# frozen_string_literal: true

require 'test_helper'

class Master::Api::Proxy::ConfigsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @user = master_account.first_admin!
    @token = FactoryBot.create(:access_token, owner: @user, scopes: 'account_management')
    host! master_account.admin_domain
  end

  test '#index get all latest proxy_configs' do
    production_current_versions = []
    proxies = FactoryBot.create_list(:proxy, 3)
    proxies.each do |proxy|
      FactoryBot.create_list(:proxy_config, 5, proxy: proxy, environment: 'sandbox')
      production_current_versions << FactoryBot.create_list(:proxy_config, 3, proxy: proxy, environment: 'production').last
    end

    get master_api_proxy_configs_path(environment: 'production'), params: {access_token: @token.value}
    assert_response :success

    assert_same_elements production_current_versions.map(&:id),
                         proxy_config_ids(response.body)
  end

  test '#index filter by host (among the latest versions)' do
    proxy = FactoryBot.create(:proxy)
    FactoryBot.create(:proxy_config, proxy: proxy, environment: 'sandbox', content: content_hosts('v1.example.com'))
    latest_proxy_config = FactoryBot.create(:proxy_config, proxy: proxy, environment: 'sandbox', content: content_hosts('v2.example.com'))

    get master_api_proxy_configs_path(environment: 'sandbox'), params: {access_token: @token.value, host: 'v2.example.com'}

    assert_response :success
    assert_equal [latest_proxy_config.id], proxy_config_ids(response.body)


    FactoryBot.create(:proxy_config, proxy: proxy, environment: 'sandbox', hosts: %w[example.com])

    get master_api_proxy_configs_path(environment: 'sandbox'), params: {access_token: @token.value, host: 'v1.example.com'}

    assert_response :success
    assert_empty proxy_config_ids(response.body)


    _old_proxy_config, new_proxy_config = FactoryBot.create_list(:proxy_config, 2, proxy: proxy, environment: 'sandbox', content: content_hosts('foo.example.com'))

    get master_api_proxy_configs_path(environment: 'sandbox'), params: {access_token: @token.value, host: 'foo.example.com'}

    assert_equal [new_proxy_config.id], proxy_config_ids(response.body)
  end

  protected

  def content_hosts(*hosts)
    { proxy: { hosts: hosts } }.to_json
  end

  def proxy_config_ids(json)
    JSON.parse(json).fetch('proxy_configs').map { |h| h.dig('proxy_config', 'id') }
  end

end
