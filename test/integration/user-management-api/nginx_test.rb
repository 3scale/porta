# frozen_string_literal: true

require 'test_helper'

class Admin::Api::NginxTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create :provider_account, domain: 'provider.example.com'
    @service = FactoryBot.create(:service, account: @provider)

    rolling_updates_on

    host! @provider.admin_domain
  end

  def spec_path
    admin_api_nginx_path + '/spec.json'
  end

  test 'spec' do
    get spec_path, params: { provider_key: @provider.provider_key }
    assert_response :success
    assert_equal("application/json", @response.content_type)
    assert_not_nil @response.body
  end

  test 'spec with wrong provider_key' do
    get spec_path, params: { provider_key: (0...8).map { (65 + rand(26)).chr }.join }
    assert_response :forbidden
  end

  test 'renders 404 on premises' do
    ThreeScale.config.stubs(apicast_custom_url: true)

    get spec_path, params: { provider_key: @provider.provider_key }

    assert_response :not_found
  end

end
