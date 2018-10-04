# frozen_string_literal: true
require 'httpclient/include_client'

class ProxyTestService
  attr_reader :proxy, :api_classifier

  # We may not have to list them all
  SOCKET_ERRORS = [
    SocketError,
    Errno::EACCES,
    Errno::EADDRINUSE,
    Errno::EADDRNOTAVAIL,
    Errno::EAFNOSUPPORT,
    Errno::EALREADY,
    Errno::EBADF,
    Errno::ECONNREFUSED,
    Errno::ECONNRESET,
    Errno::EFAULT,
    Errno::EHOSTUNREACH,
    Errno::EINPROGRESS,
    Errno::EINTR,
    Errno::EISCONN,
    Errno::EINVAL,
    Errno::ENAMETOOLONG,
    Errno::ENETDOWN,
    Errno::ENETUNREACH,
    Errno::ENOBUFS,
    Errno::ENOSR,
    Errno::ENOTSOCK,
    Errno::EOPNOTSUPP,
    Errno::EPROTOTYPE,
    Errno::ETIMEDOUT,
    Errno::EIO,
    Errno::ELOOP,
    Errno::ENAMETOOLONG,
    Errno::ENOENT,
    Errno::ENOTDIR,
  ].freeze

  NETWORK_ERRORS = [
    HTTPClient::BadResponseError, HTTPClient::TimeoutError,
    OpenSSL::SSL::SSLError,
    *SOCKET_ERRORS
  ].freeze

  extend ::HTTPClient::IncludeClient

  class_attribute :config
  self.config = ThreeScale.config.sandbox_proxy.dup.freeze

  include_http_client do |client|
    client.debug_dev = $stdout if config.debug

    client.connect_timeout = 10
    client.send_timeout = 10
    client.receive_timeout = 10

    client.transparent_gzip_decompression = true
    client.force_basic_auth = true

    if (verify_mode = config.verify_mode)
      client.ssl_config.verify_mode = verify_mode
    end
  end

  def initialize(proxy)
    @proxy = proxy
    @api_classifier = ApiClassificationService.new(test_hosts: config.ignore_test_failures)
  end

  def disabled?
    !proxy&.deployable?
  end

  def credentials
    credentials = proxy.authentication_params_for_proxy

    case proxy.credentials_location
    when 'headers'
      { header: credentials }
    when 'query'
      { query: credentials }
    when 'authorization'
      user, password = proxy.authorization_credentials
      { header: { 'Authorization' => ["#{user}:#{password}"].pack('m').tr("\n", '') }}
    end
  end

  def api_test_path
    uri = URI(proxy.sandbox_endpoint.to_s)

    if (override = config.override)
      uri = URI(override)
    end

    uri.merge!(proxy.api_test_path.to_s)

    uri
  end

  def api_test_host
    URI(proxy.sandbox_endpoint.to_s).host
  end

  def perform
    uri = api_test_path

    response = test_request(uri)

    status = SuccessfulResponse.new(uri, response.code, response.headers, response.body)
    status.extend(IgnoreFailures) if ignore_failures?
    status
  rescue *NETWORK_ERRORS => error
    TransportError.new(uri, error)
  rescue URI::BadURIError => error
    TransportError.new(uri, error, 'Invalid URL')
  end

  private

  def test_request(uri)
    headers = { 'Host' => api_test_host }
    headers['X-3scale-debug'] = proxy.service.account.provider_key if config.debug

    http_client.get(uri, credentials.deep_merge(header: headers))
  end

  def ignore_failures?
    api_classifier.test(@proxy.api_backend).test_api?
  end

  module IgnoreFailures
    def success?
      true
    end
  end

  module ProxyResponse
    attr_reader :code, :uri

    def initialize(uri, *)
      @uri = uri
      @code ||= nil
    end

    def success?
      HTTP::Status.successful?(code)
    end
  end

  class SuccessfulResponse
    include ProxyResponse
    attr_reader :body, :code

    def initialize(_, code, headers, body)
      super
      @code = code
      @headers = headers
      @body = body
    end

    def error
      ["Test request failed with HTTP code #{code}", body] unless success?
    end
  end

  class TransportError
    include ProxyResponse
    attr_reader :exception

    def initialize(_, exception, message = exception.message)
      super
      @exception = exception
      @message = message
    end

    def error
      ['Test request failed', exception.message]
    end
  end

  private_constant :TransportError, :SuccessfulResponse, :ProxyResponse
end
