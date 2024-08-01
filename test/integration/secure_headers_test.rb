require 'test_helper'

class SecureHeadersTest < ActionDispatch::IntegrationTest
  def setup
    provider = FactoryBot.create(:provider_account)
    login! provider
  end

  test 'adds secure headers in the response' do
    https!

    get provider_admin_dashboard_path

    assert_includes response.headers, 'X-Request-Id'
    assert_equal 'DENY', response.headers['X-Frame-Options']
    assert_equal 'nosniff', response.headers['X-Content-Type-Options']
    assert_equal '1; mode=block', response.headers['X-XSS-Protection']
    assert_equal "default-src * data: mediastream: blob: filesystem: ws: wss: 'unsafe-eval' 'unsafe-inline'", response.headers['Content-Security-Policy']
  end

  test 'do not add non used secure headers in the response' do
    https!

    get provider_admin_dashboard_path

    refute_includes response.headers, 'X-Download-Options'
    refute_includes response.headers, 'Strict-Transport-Security'
    refute_includes response.headers, 'X-Permitted-Cross-Domain-Policies'
  end

end
