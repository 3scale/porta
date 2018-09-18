require 'test_helper'

class ProxyTestServiceTest < ActiveSupport::TestCase

  def setup
    @proxy = FactoryGirl.build_stubbed(:proxy)
    @service = ProxyTestService.new(@proxy)
  end

  def test_api_test_path
    @proxy.sandbox_endpoint = 'http://example.com'
    @proxy.api_test_path = 'api_test_path'

    assert_equal 'http://example.com/api_test_path', @service.api_test_path.to_s

    @service.config = @service.config.merge(override: 'https://example.net:8090/path/')
    assert_equal 'https://example.net:8090/path/api_test_path', @service.api_test_path.to_s
  end

  def test_api_test_host
    @proxy.sandbox_endpoint = 'http://example.com:8080'

    assert_equal 'example.com', @service.api_test_host
  end

  def test_credentials
    @proxy.stubs(:authentication_params_for_proxy).returns({user_key: 'abcd'})

    assert_equal({query: {user_key: 'abcd'}}, @service.credentials)

    @proxy.credentials_location = 'headers'
    assert_equal({header: {user_key: 'abcd'}}, @service.credentials)
  end

  def test_client
    client = @service.http_client

    assert_equal 10, client.connect_timeout
    assert_equal 10, client.send_timeout
    assert_equal 10, client.receive_timeout
  end

  def test_perform
    @proxy.service.expects(:plugin_authentication_params).returns(user_key: 'SOME_KEY').at_least_once

    @proxy.sandbox_endpoint = nil
    @proxy.api_test_path = nil

    refute @service.perform.success?, 'invalid url should fail'

    @proxy.api_backend = 'http://api-sentiment.3scale.net'
    @proxy.sandbox_endpoint = 'http://proxy:80'
    @proxy.api_test_path = '/v1/word/stuff.json'
    @proxy.secret_token = '123'

    assert_equal 'http://proxy/v1/word/stuff.json', @service.api_test_path.to_s
    successful_request = stub_request(:get, 'http://proxy/v1/word/stuff.json?user_key=SOME_KEY')
        .to_return(status: 200)

    result = @service.perform
    assert result.success?, 'result should be successful'
    assert_empty Array(result.error)
    assert_requested successful_request

    @proxy.api_test_path = '/v2/word/stuff.json'
    assert_equal 'http://proxy/v2/word/stuff.json', @service.api_test_path.to_s
    failed_request = stub_request(:get, 'http://proxy/v2/word/stuff.json?user_key=SOME_KEY')
                         .to_return(status: 500, body: 'some body')

    result = @service.perform
    refute result.success?, 'api_test_request did not fail'
    assert_equal ['Test request failed with HTTP code 500', 'some body'], result.error
    assert_requested failed_request

    @proxy.credentials_location = 'headers'
    headers_credentials = stub_request(:get, 'http://proxy' + @proxy.api_test_path).with(headers: {'User-Key' => 'SOME_KEY'})
    assert @service.perform.success?
    assert_requested headers_credentials

    overriden_host = stub_request(:get, 'https://example.com/v2/word/stuff.json')
                       .with(headers: { 'Host' => 'proxy' })
                       .to_return(status: 200)

    @service.config = @service.config.merge(override: 'https://example.com')

    assert @service.perform.success?
    assert_requested overriden_host

    @proxy.api_test_path = '/v2/net/error.json'
    assert_equal 'https://example.com/v2/net/error.json', @service.api_test_path.to_s
    failed_request = stub_request(:get, 'https://example.com/v2/net/error.json')
                         .to_raise(Errno::EHOSTUNREACH.new('proxy'))
    result = @service.perform
    assert_requested failed_request
    assert result.error

  end
end
