# frozen_string_literal: true

require 'test_helper'

class Sites::DnsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account, domain: 'provider.example.net', from_email: 'support@example.net')
    login! @provider
  end

  test 'update' do
    account_params = {
      account: {
        site_access_code: 'abcdefgh',
        domain: 'another.dev.example.net',
        from_email: 'info@dev.example.net'
      }
    }

    Rails.configuration.three_scale.stubs(readonly_custom_domains_settings: true)
    put admin_site_dns_path, params: account_params

    @provider.reload
    assert_equal 'abcdefgh', @provider.site_access_code
    assert_equal 'provider.example.net', @provider.domain
    assert_equal 'support@example.net', @provider.from_email


    Rails.configuration.three_scale.stubs(readonly_custom_domains_settings: false)
    put admin_site_dns_path, params: account_params

    @provider.reload
    assert_equal 'abcdefgh', @provider.site_access_code
    assert_equal 'another.dev.example.net', @provider.domain
    assert_equal 'info@dev.example.net', @provider.from_email

  end

  test 'update shows an error message when fails' do
    Rails.application.config.three_scale.stubs(readonly_custom_domains_settings: false)
    put admin_site_dns_path, params: { account: {domain: 'INVALID'} }
    assert_match 'Domain must be downcase', flash[:error]
  end
end
