# frozen_string_literal: true

require 'test_helper'

class Api::ProxyConfigsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider)
    @service = FactoryBot.create(:simple_service, :with_default_backend_api, account: provider)
    @admin = FactoryBot.create(:simple_admin, account: provider, username: 'some-user')
    @admin.activate!

    login! provider, user: @admin
  end

  attr_reader :service, :admin, :provider
  delegate :proxy, to: :service

  test 'index sandbox' do
    config = FactoryBot.create(:proxy_config, proxy: proxy, user: admin, environment: 'sandbox')

    get admin_service_proxy_configs_path(service_id: service, environment: 'sandbox')

    assert_response :success
    assert_equal [config.id], assigns['proxy_configs'].map(&:id)
    assert_select 'td', text: 'some-user'
    assert_select 'a', text: "apicast-config-#{service.parameterized_name}-#{config.environment}-#{config.version}.json"
  end

  test 'index production' do
    config = FactoryBot.create(:proxy_config, proxy: proxy, user: admin, environment: 'production')

    get admin_service_proxy_configs_path(service_id: service, environment: 'production')

    assert_response :success
    assert_equal [config.id], assigns['proxy_configs'].map(&:id)
    assert_select 'td', text: 'some-user'
    assert_select 'a', text: "apicast-config-#{service.parameterized_name}-#{config.environment}-#{config.version}.json"
  end

  test 'index shows the user display_name' do
    users = [admin, FactoryBot.create(:member, account: provider)]
    config = (users | [nil]).map { |user| FactoryBot.create(:proxy_config, proxy: proxy, user: user, environment: 'production') }

    get admin_service_proxy_configs_path(service_id: service, environment: 'production')

    page = Nokogiri::HTML4::Document.parse(response.body)
    expected_display_names = users.map { |user| user.decorate.display_name } | ['']
    assert_same_elements expected_display_names, page.xpath('//table/tbody/tr/td[4]').map(&:text)
  end

  test 'show' do
    config = FactoryBot.create(:proxy_config, proxy: proxy, content: '{"foo":"bar"}')

    get admin_service_proxy_config_path(service_id: service.id, id: config.id)

    assert_response :success
    assert_equal '{"foo":"bar"}', response.body
  end
end
