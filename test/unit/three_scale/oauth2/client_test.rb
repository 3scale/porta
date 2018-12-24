require 'test_helper'

class ThreeScale::OAuth2::ClientTest < ActiveSupport::TestCase

  setup do
    @authentication_provider = FactoryBot.build_stubbed(:authentication_provider)
    @client = ThreeScale::OAuth2::Client.build(@authentication_provider)
  end

  test '#callback_url' do
    base_url = 'http://example.net'
    expected_url = "http://example.net/auth/#{@authentication_provider.system_name}/callback"

    assert_equal expected_url, @client.callback_url(base_url)
  end

  test '#authorize_url' do
    base_url = 'http://example.net'
    authorize_url = @client.authorize_url(base_url)

    uri = URI.parse(authorize_url)
    params = CGI.parse(uri.query)

    assert_equal @authentication_provider.client_id, params["client_id"][0]
    assert_equal "http://example.net/auth/#{@authentication_provider.system_name}/callback", params["redirect_uri"][0]
  end

  %i[github_authentication_provider keycloak_authentication_provider self_authentication_provider].each do |factory|
    test "ssl verification mode #{factory}" do
      [OpenSSL::SSL::VERIFY_NONE, OpenSSL::SSL::VERIFY_PEER].each do |mode|
        authentication_provider = FactoryBot.build_stubbed(factory)
        authentication_provider.stubs(ssl_verify_mode: mode)

        client = ThreeScale::OAuth2::Client.build(authentication_provider)
        assert_equal authentication_provider.ssl_verify_mode, client.client.connection.ssl.verify_mode
      end
    end
  end
end
