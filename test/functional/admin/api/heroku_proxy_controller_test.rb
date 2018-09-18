require 'test_helper'

class Admin::Api::HerokuProxyControllerTest < ActionDispatch::IntegrationTest

  test 'post deployed' do
    provider = Factory :provider_account, :domain => 'provider.example.com'
    host! provider.admin_domain

    post(admin_api_heroku_proxy_deployed_path(format: :xml),
              :provider_key => provider.api_key)

    assert_response :success
  end
end