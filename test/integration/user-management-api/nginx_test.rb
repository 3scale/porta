require 'test_helper'

class Admin::Api::NginxTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create :provider_account, domain: 'provider.example.com'
    @service = FactoryBot.create(:service, account: @provider)

    rolling_updates_on

    host! @provider.admin_domain
  end

  test 'show' do
    get admin_api_nginx_path, {format: :zip, provider_key: @provider.provider_key}
    assert_response :success
    assert_equal( "application/zip", @response.content_type )
    assert_not_nil @response.body
  end

  test 'show with wrong provider_key' do
    get admin_api_nginx_path, { format: :zip, provider_key: (0...8).map { (65 + rand(26)).chr }.join }
    assert_response :forbidden
  end

  test 'renders 404 on premises' do
    ThreeScale.config.stubs(apicast_custom_url: true)

    get admin_api_nginx_path, {format: :zip, provider_key: @provider.provider_key}

    assert_response :not_found
  end

end
