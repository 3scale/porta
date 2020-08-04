# frozen_string_literal: true

require 'test_helper'

class ProxyTestServiceTest < ActiveSupport::TestCase

  def setup
    @proxy = FactoryBot.build_stubbed(:proxy)
    @test_service = ProxyTestService.new(proxy)
  end

  attr_reader :proxy, :test_service

  test '#api_test_path' do
    proxy.sandbox_endpoint = 'http://example.com'
    proxy.api_test_path = 'api_test_path'

    assert_equal 'http://example.com/api_test_path', test_service.api_test_path.to_s

    test_service.config = test_service.config.merge(override: 'https://example.net:8090/path/')
    assert_equal 'https://example.net:8090/path/api_test_path', test_service.api_test_path.to_s
  end

  test '#api_test_path with backend api config path' do
    proxy = FactoryBot.create(:proxy)
    proxy.service.backend_api_configs.first.update(path: '/echo')
    proxy.sandbox_endpoint = 'http://example.com'
    proxy.api_test_path = 'hello'
    test_service = ProxyTestService.new(proxy)

    assert_equal 'http://example.com/echo/hello', test_service.api_test_path.to_s
  end

  test '#api_test_host' do
    proxy.sandbox_endpoint = 'http://example.com:8080'

    assert_equal 'example.com', test_service.api_test_host
  end

  test '#credentials' do
    proxy.stubs(:authentication_params_for_proxy).returns({user_key: 'abcd'})

    assert_equal({query: {user_key: 'abcd'}}, test_service.credentials)

    proxy.credentials_location = 'headers'
    assert_equal({header: {user_key: 'abcd'}}, test_service.credentials)

    proxy.credentials_location = 'authorization'

    encoded_string = Base64.encode64("abcd:").strip
    assert_equal({header: {'Authorization' => "Basic #{encoded_string}"}}, test_service.credentials)

    proxy.stubs(:authentication_params_for_proxy).returns({app_id: 'abcd', app_key: 'efgh'})
    encoded_string = Base64.encode64("abcd:efgh").strip
    assert_equal({header: {'Authorization' => "Basic #{encoded_string}"}}, test_service.credentials)
  end

  test 'http client options' do
    client = test_service.http_client

    assert_equal 10, client.connect_timeout
    assert_equal 10, client.send_timeout
    assert_equal 10, client.receive_timeout
  end

  test '#perform' do
    proxy.service.expects(:plugin_authentication_params).returns(user_key: 'SOME_KEY').at_least_once

    proxy.sandbox_endpoint = nil
    proxy.api_test_path = nil

    refute test_service.perform.success?, 'invalid url should fail'

    proxy.api_backend = 'http://api-sentiment.3scale.net'
    proxy.sandbox_endpoint = 'http://proxy:80'
    proxy.api_test_path = '/v1/word/stuff.json'
    proxy.secret_token = '123'

    assert_equal 'http://proxy/v1/word/stuff.json', test_service.api_test_path.to_s
    successful_request = stub_request(:get, 'http://proxy/v1/word/stuff.json?user_key=SOME_KEY')
        .to_return(status: 200)

    result = test_service.perform
    assert result.success?, 'result should be successful'
    assert_empty Array(result.error)
    assert_requested successful_request

    proxy.api_test_path = '/v2/word/stuff.json'
    assert_equal 'http://proxy/v2/word/stuff.json', test_service.api_test_path.to_s
    failed_request = stub_request(:get, 'http://proxy/v2/word/stuff.json?user_key=SOME_KEY')
                         .to_return(status: 500, body: 'some body')

    result = test_service.perform
    refute result.success?, 'api_test_request did not fail'
    assert_equal ['Test request failed with HTTP code 500', 'some body'], result.error
    assert_requested failed_request

    proxy.credentials_location = 'headers'
    headers_credentials = stub_request(:get, 'http://proxy' + proxy.api_test_path).with(headers: {'User-Key' => 'SOME_KEY'})
    assert test_service.perform.success?
    assert_requested headers_credentials

    overriden_host = stub_request(:get, 'https://example.com/v2/word/stuff.json')
                       .with(headers: { 'Host' => 'proxy' })
                       .to_return(status: 200)

    test_service.config = test_service.config.merge(override: 'https://example.com')

    assert test_service.perform.success?
    assert_requested overriden_host

    proxy.api_test_path = '/v2/net/error.json'
    assert_equal 'https://example.com/v2/net/error.json', test_service.api_test_path.to_s
    failed_request = stub_request(:get, 'https://example.com/v2/net/error.json')
                         .to_raise(Errno::EHOSTUNREACH.new('proxy'))
    result = test_service.perform
    assert_requested failed_request
    assert result.error

  end

  test '#disabled?' do
    proxy.stubs(deployment_option: 'service_mesh_istio')
    assert test_service.disabled?
  end
end
