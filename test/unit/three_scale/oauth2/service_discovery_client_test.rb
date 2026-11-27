# frozen_string_literal: true

require 'test_helper'

class ThreeScale::OAuth2::ServiceDiscoveryClientTest < ActiveSupport::TestCase
  class RedirectUriTest < ActiveSupport::TestCase
    RedirectUri = ThreeScale::OAuth2::ServiceDiscoveryClient::RedirectUri

    setup do
      authentication_provider = FactoryBot.build_stubbed(:authentication_provider)
      authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)
      @client = ThreeScale::OAuth2::ServiceDiscoveryClient.new(authentication)
      @system_name = authentication_provider.system_name

      env = {
        'HTTP_HOST' => 'example.net',
        'QUERY_STRING' => 'referrer=%2Fp%2Fadmin%2Fdashboard%3Ffoo%3Dbar&code=12456',
        'PATH_INFO' => '/path'
      }
      @request = ActionDispatch::TestRequest.create(env)
      @master_domain = master_account.external_admin_domain
    end

    test 'builtin OAuth server: the callback url is percent-decoded' do
      ThreeScale.config.service_discovery.stubs(oauth_server_type: 'builtin')

      assert_equal "http://#{@master_domain}/auth/#{@system_name}/callback?referrer=/p/admin/dashboard?foo=bar&self_domain=example.net",
                   RedirectUri.call(@client, @request)
    end

    test 'rh_sso OAuth server: the callback url is left encoded' do
      ThreeScale.config.service_discovery.stubs(oauth_server_type: 'rh_sso')

      assert_equal "http://#{@master_domain}/auth/#{@system_name}/callback?referrer=%2Fp%2Fadmin%2Fdashboard%3Ffoo%3Dbar&self_domain=example.net",
                   RedirectUri.call(@client, @request)
    end
  end
end
