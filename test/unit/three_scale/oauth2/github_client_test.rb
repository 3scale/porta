require 'test_helper'

class ThreeScale::OAuth2::GitHubClientTest < ActiveSupport::TestCase

  setup do
    authentication_provider = FactoryBot.build_stubbed(:authentication_provider)
    @authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)

    @oauth2 = ThreeScale::OAuth2::GitHubClient.new(@authentication)
    @oauth2.stubs(:raw_info).returns({'id' => '1234', 'login' => 'quentin', 'company' => 'org'})
  end

  test '#uid' do
    assert_equal '1234', @oauth2.uid
  end

  test '#email_verified?' do
    assert @oauth2.email_verified?
  end

  test '#username' do
    assert_equal 'quentin', @oauth2.username
  end

  test '#kind' do
    assert_equal 'github', @oauth2.kind
  end

  test '#org_name' do
    assert_equal 'org', @oauth2.org_name
  end

  test '#access_token in Authorization HTTP header' do
    access_token = ::OAuth2::AccessToken.from_hash(@oauth2.client, access_token: 'some-access-token')
    @oauth2.expects(:access_token).returns(access_token).at_least_once
    stub_request(:get, "https://api.github.com/user/emails")
      .with(:headers => {'Accept'=>'application/vnd.github.v3', 'Authorization'=>'Bearer some-access-token'})
      .to_return(status: 200, body: '[]', headers: { 'Content-Type' => 'application/json' })
    @oauth2.email
   end
end
