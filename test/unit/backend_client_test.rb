# frozen_string_literal: true

require 'test_helper'

class BackendClientTest < ActiveSupport::TestCase
  test 'normalize host and port' do
    Rails.application.config.stubs(backend_client: {
      host: 'backend-host:8443',
      secure: true
    })
    assert_equal({host: 'backend-host', port: 8443, secure: true}, BackendClient.threescale_client_config)
  end

  test 'set default port for https' do
    Rails.application.config.stubs(backend_client: {
      host: 'backend-host',
      secure: true
    })
    assert_equal({host: 'backend-host', port: 443, secure: true}, BackendClient.threescale_client_config)
  end

  test 'set default port for http' do
    Rails.application.config.stubs(backend_client: {
      host: 'backend-host',
      secure: false
    })
    assert_equal({host: 'backend-host', port: 80, secure: false}, BackendClient.threescale_client_config)
  end
end
