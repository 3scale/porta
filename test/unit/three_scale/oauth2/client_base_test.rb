require 'test_helper'

class ThreeScale::OAuth2::ClientBaseTest < ActiveSupport::TestCase

  setup do
    authentication_provider = FactoryGirl.build_stubbed(:authentication_provider)
    @authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)
    @oauth2 = ThreeScale::OAuth2::ClientBase.new(@authentication)
  end

  def test_fetch_raw_info
    access_token = mock('access_token', get: OpenStruct.new(parsed: nil))
    @oauth2.stubs(:access_token).returns(access_token)
    @oauth2.fetch_raw_info
    
    assert_equal({}, @oauth2.raw_info)
  end

  test '#new' do
    assert_equal @authentication, @oauth2.authentication
    assert @oauth2.client
    assert_equal({}, @oauth2.raw_info)
  end

  test '#callback_url' do
    expected_url = "http://example.com/lol/auth/#{@authentication.system_name}/callback?foo=bar"
    assert_equal expected_url, @oauth2.callback_url('http://example.com/lol', foo: :bar)
  end

  test '#email' do
    assert_nil @oauth2.email
  end

  test '#email_verified?' do
    refute @oauth2.email_verified?
  end

  test '#username' do
    assert_nil @oauth2.username
  end

  test '#uid' do
    @oauth2.expects(:raw_info).returns({ @authentication.identifier_key => '1234' })
    assert_equal '1234', @oauth2.uid

    @oauth2.expects(:raw_info).returns({})
    assert_nil @oauth2.uid
  end

  test 'ssl certificate error' do
    error = Faraday::SSLError.new('Faraday::SSLError: hostname "example.com" does not match the server certificate')

    stub_request(:post, 'http://example.com/oauth/token').to_raise(error)

    assert response = @oauth2.authenticate!('code', mock('request'))

    assert_equal I18n.t('errors.messages.oauth.invalid_certificate'), response.error
  end

  test 'connection failure' do
    error = Faraday::ConnectionFailed.new('Failed to open TCP connection to localhost:8080 (Connection refused - connect(2) for "localhost" port 8080)')

    stub_request(:post, 'http://example.com/oauth/token').to_raise(error)

    assert response = @oauth2.authenticate!('code', mock('request'))

    assert_equal I18n.t('errors.messages.oauth.connection_failed'), response.error
  end

  test 'faraday client error' do
    (Faraday::ClientError.descendants - [Faraday::SSLError, Faraday::ConnectionFailed]).each do |klass|
      error = klass.new("#{klass}: generic error")

      stub_request(:post, 'http://example.com/oauth/token').to_raise(error)

      assert response = @oauth2.authenticate!('code', mock('request'))

      assert_equal I18n.t('errors.messages.oauth.client_error', message: error.message), response.error
    end
  end

  test 'faraday client errors are transported within ErrorData' do
    error = Faraday::ClientError.new('Generic error')

    stub_request(:post, 'http://example.com/oauth/token').to_raise(error)

    assert response = @oauth2.authenticate!('code', mock('request'))

    assert_kind_of ThreeScale::OAuth2::ErrorData, response
    assert_equal I18n.t('errors.messages.oauth.client_error', message: error.message), response.error
  end

  test 'standard errors are not transported within ErrorData' do
    error = StandardError.new('Generic error')

    stub_request(:post, 'http://example.com/oauth/token').to_raise(error)

    assert_raise StandardError do
      @oauth2.authenticate!('code', mock('request'))
    end
  end

  class CallbackUrlTest < ActiveSupport::TestCase

    CallbackUrl = ThreeScale::OAuth2::ClientBase::CallbackUrl

    def test_call
      expected_url_1 = 'http://example.com/wild/auth/github/callback?foo=bar'
      assert_equal expected_url_1, CallbackUrl.call('http://example.com/wild', 'github', foo: :bar)

      expected_url_2 = 'http://example.com/wild/auth/github/callback'
      assert_equal expected_url_2, CallbackUrl.call('http://example.com/wild', 'github', {})
      assert_equal expected_url_2, CallbackUrl.call('http://example.com/wild/auth', 'github', {})
    end
  end
end
