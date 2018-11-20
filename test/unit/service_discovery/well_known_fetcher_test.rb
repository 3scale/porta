# frozen_string_literal: true

require 'test_helper'

class ServiceDiscovery::WellKnownFetcherTest < ActiveSupport::TestCase
  include ServiceDiscovery::Config

  def setup
    config = ActiveSupport::OrderedOptions.new
    config.merge!(
      enabled: true,
      server_scheme: 'https',
      server_port: 8443,
      server_host: 'localhost',
      authentication_method: 'oauth',
      verify_ssl: OpenSSL::SSL::VERIFY_NONE
    )
    ThreeScale.config.stubs(service_discovery: config)
    @subject = ServiceDiscovery::WellKnownFetcher.new
  end

  attr_reader :subject

  test 'call' do
    request = mock
    request.expects(:execute)
    RestClient::Request.expects(:new).with(
      method: :get,
      url: well_known_url,
      verify_ssl: verify_ssl,
      timeout: timeout,
      open_timeout: open_timeout,
      log: Rails.logger
    ).returns(request)
    subject.call
  end

  test 'call successful' do
    stub_request(:get, well_known_url).to_return(status: 200, body: well_known_response.to_json)

    config = subject.call
    expected_config = ActiveSupport::OrderedOptions.new.merge(
      well_known_response.merge(userinfo_endpoint: 'https://localhost:8443/apis/user.openshift.io/v1/users/~')
    )
    assert_equal config, expected_config
  end

  test 'call failed' do
    stub_request(:get, well_known_url).to_return(status: 500, body: '')
    assert_nil, subject.call

    stub_request(:get, well_known_url).to_return(status: 200, body: '<xml></xml>')
    assert_nil, subject.call
  end

  private

  def well_known_response
    {
      issuer: 'https://127.0.0.1.nip.io:8443',
      authorization_endpoint: 'https://127.0.0.1.nip.io:8443/oauth/authorize',
      token_endpoint: 'https://127.0.0.1.nip.io:8443/oauth/token',
      scopes_supported: %w(user:check-access user:full user:info user:list-projects user:list-scoped-projects),
      response_types_supported: ['code', 'token'],
      grant_types_supported: ['authorization_code', 'implicit'],
      code_challenge_methods_supported: ['plain', 'S256'],
    }
  end
end
