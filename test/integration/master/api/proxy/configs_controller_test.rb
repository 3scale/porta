require 'test_helper'

class Master::Api::Proxy::ConfigsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryGirl.create(:provider_account)
    @user = master_account.first_admin!
    @token = FactoryGirl.create(:access_token, owner: @user, scopes: 'account_management')
    host! master_account.admin_domain
  end

  test '#index get all latest proxy_configs' do
    proxies = FactoryGirl.create_list(:proxy, 3)
    proxies.each do |proxy|
      FactoryGirl.create_list(:proxy_config, 5, proxy: proxy, environment: 'sandbox')
      FactoryGirl.create_list(:proxy_config, 3, proxy: proxy, environment: 'production')
    end

    get master_api_proxy_configs_path(environment: 'production'), access_token: @token.value
    assert_response :success

    assert_same_elements ProxyConfig.current_versions.by_environment('production').map(&:id),
                         proxy_config_ids(response.body)
  end

  test '#index filter by host' do
    proxy = FactoryGirl.create(:proxy)
    FactoryGirl.create(:proxy_config, proxy: proxy, environment: 'sandbox', hosts: %w[example.com])
    proxy_config = FactoryGirl.create(:proxy_config, proxy: proxy, environment: 'sandbox', hosts: %w[lvh.me])

    get master_api_proxy_configs_path(environment: 'sandbox', host: 'lvh.me'), access_token: @token.value
    assert_response :success

    assert_same_elements [ proxy_config.id ],
                         proxy_config_ids(response.body)

  end

  protected

  def proxy_config_ids(json)
    JSON.parse(json).fetch('proxy_configs').map { |h| h.dig('proxy_config', 'id') }
  end


end
