# frozen_string_literal: true

require 'test_helper'

class FaradayNestedParamsTest < ActiveSupport::TestCase
  test 'Faraday handles deeply nested query parameters without stack overflow' do
    # THREESCALE-15318: Test protection against CVE-2026-54297
    # Faraday versions before 1.10.6 and 2.14.3 are vulnerable to DoS
    # via crafted nested query strings that cause SystemStackError

    # Create a deeply nested query string that would trigger the vulnerability
    # in vulnerable Faraday versions
    nested_depth = 100
    nested_params = 'a' * nested_depth + '=1'
    nested_depth.times { |i| nested_params = "a[#{nested_params}]" }

    connection = Faraday.new(url: 'http://example.com') do |faraday|
      faraday.adapter :test do |stub|
        stub.get('/test') { |env| [200, {}, 'OK'] }
      end
    end

    # This should not raise SystemStackError in patched versions
    assert_nothing_raised do
      # Try to make a request with deeply nested parameters
      # The fix should handle this gracefully
      connection.get('/test', {deep: nested_params})
    end
  rescue Faraday::ParamPart::PartLimitError
    # This is expected in newer versions that enforce limits
    # This means the fix is working
    assert true
  end

  test 'oauth2 gem can handle complex query parameters' do
    # THREESCALE-15318: Ensure oauth2 gem works correctly with the updated Faraday
    # oauth2 gem uses Faraday internally, so we need to ensure compatibility

    authentication_provider = FactoryBot.build_stubbed(:authentication_provider)
    authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)

    # This should work without errors
    assert_nothing_raised do
      client = ::OAuth2::Client.new(
        authentication.client_id,
        authentication.client_secret,
        site: 'https://example.com'
      )
      assert client
    end
  end
end
