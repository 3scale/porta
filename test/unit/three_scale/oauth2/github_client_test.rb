require 'test_helper'

class ThreeScale::OAuth2::GithubClientTest < ActiveSupport::TestCase

  setup do
    authentication_provider = FactoryBot.build_stubbed(:authentication_provider)
    @authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)

    @oauth2 = ThreeScale::OAuth2::GithubClient.new(@authentication)
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
end
