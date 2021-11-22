# frozen_string_literal: true

require 'test_helper'

class Api::ProxyRulesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = FactoryBot.create(:service, account: @provider)
    login! @provider
  end

  test '#index page list all proxy rules' do
    proxy_rules = FactoryBot.create_list(:proxy_rule, 2, proxy: @service.proxy)

    get admin_service_proxy_rules_path(@service)
    page = Nokogiri::HTML::Document.parse(response.body)
    patterns = page.xpath('//*[@id="proxy-rules"]/tbody/tr/td[2]').text

    assert_response :ok
    proxy_rules.map(&:pattern).each do |pattern|
      patterns.include?(pattern)
    end
  end

  test '#index page should not return the Redirect header when not using proxy pro' do
    Service.any_instance.stubs(:using_proxy_pro?).returns(false)
    proxy_rules = FactoryBot.create(:proxy_rule, proxy: @service.proxy)

    get admin_service_proxy_rules_path(@service)
    refute_match /Redirect/, response.body
  end

  test '#index page should return the Redirect header when using proxy pro' do
    Service.any_instance.stubs(:using_proxy_pro?).returns(true)
    proxy_rules = FactoryBot.create(:proxy_rule, proxy: @service.proxy)

    get admin_service_proxy_rules_path(@service)
    assert_match /Redirect/, response.body
  end


  test '#create persists a new proxy rule' do
    proxy_rule_params = FactoryBot.attributes_for(:proxy_rule, proxy: @service.proxy, metric_id: @service.metrics.last.id)

    assert_difference -> { @service.proxy.proxy_rules.count }, 1 do
      post admin_service_proxy_rules_path(@service), params: { proxy_rule: proxy_rule_params }
    end
  end

  test '#update saves the new attributes' do
    proxy_rule = FactoryBot.create(:proxy_rule, proxy: @service.proxy)

    patch admin_service_proxy_rule_path(@service, proxy_rule), params: { proxy_rule: { pattern: '/testing' } }
    follow_redirect!
    proxy_rule.reload

    assert_response :ok
    assert_equal '/testing', proxy_rule.pattern
  end

  test '#destroy deletes the proxy rule' do
    proxy_rule = FactoryBot.create(:proxy_rule, proxy: @service.proxy)

    assert_difference -> { @service.proxy.proxy_rules.count }, -1 do
      delete admin_service_proxy_rule_path(@service, proxy_rule)
      follow_redirect!

      assert_response :success
    end
  end
end
