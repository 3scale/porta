# frozen_string_literal: true

require 'test_helper'

class Sites::AdminSecurityTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
    host! @provider.external_admin_domain
    Rails.cache.clear
  end

  test 'edit without captcha' do
    Recaptcha.expects(:captcha_configured?).returns(false).twice
    get edit_provider_admin_security_path
    assert_response :success
    assert_match 'reCAPTCHA has not been configured correctly', response.body
  end

  test 'edit with captcha' do
    Recaptcha.expects(:captcha_configured?).returns(true).twice
    get edit_provider_admin_security_path
    assert_response :success
    assert_not_match 'reCAPTCHA has not been configured correctly', response.body
  end

  test 'displays Permissions-Policy header field' do
    get edit_provider_admin_security_path
    assert_response :success
    assert_match 'Permissions-Policy Header', response.body
  end

  test 'updates Permissions-Policy header' do
    policy_value = 'camera=(), microphone=()'

    put provider_admin_security_path, params: {
      settings: {
        admin_bot_protection_level: 'none',
        permissions_policy_header_admin: policy_value
      }
    }

    assert_redirected_to edit_provider_admin_security_path

    @provider.reload
    setting = @provider.account_settings.find_by(type: 'PermissionsPolicyHeaderAdmin')
    assert_equal policy_value, setting.value
  end

  test 'updates admin bot protection level setting' do
    put provider_admin_security_path, params: {
      settings: {
        admin_bot_protection_level: 'captcha'
      }
    }

    assert_redirected_to edit_provider_admin_security_path

    @provider.settings.reload
    assert_equal :captcha, @provider.settings.admin_bot_protection_level
  end

  test 'omitting header field deletes existing setting' do
    @provider.account_settings.create!(
      type: 'PermissionsPolicyHeaderAdmin',
      value: 'camera=()'
    )

    # Submit without permissions_policy_header_admin param (checkbox unchecked)
    put provider_admin_security_path, params: {
      settings: { admin_bot_protection_level: 'none' }
    }

    assert_redirected_to edit_provider_admin_security_path
    assert_nil @provider.account_settings.find_by(type: 'PermissionsPolicyHeaderAdmin')
  end

  test 'omitting header field when no setting exists does not break' do
    put provider_admin_security_path, params: {
      settings: { admin_bot_protection_level: 'none' }
    }

    assert_redirected_to edit_provider_admin_security_path
    assert_nil @provider.account_settings.find_by(type: 'PermissionsPolicyHeaderAdmin')
  end

  test 'displays Content-Security-Policy Header field' do
    get edit_provider_admin_security_path
    assert_response :success
    assert_match 'Content-Security-Policy Header', response.body
  end

  test 'updates Content-Security-Policy header' do
    csp_value = "default-src 'self'; script-src 'self'"

    put provider_admin_security_path, params: {
      settings: {
        admin_bot_protection_level: 'none',
        csp_header_admin: csp_value
      }
    }

    assert_redirected_to edit_provider_admin_security_path

    @provider.reload
    setting = @provider.account_settings.find_by(type: 'CspHeaderAdmin')
    assert_equal csp_value, setting.value
  end

  test 'updates Content-Security-Policy header to a blank value' do
    put provider_admin_security_path, params: {
      settings: {
        admin_bot_protection_level: 'none',
        csp_header_admin: ''
      }
    }

    assert_redirected_to edit_provider_admin_security_path

    @provider.reload
    setting = @provider.account_settings.find_by(type: 'CspHeaderAdmin')
    assert setting.value.blank?
  end

  test 'omitting CSP header field deletes existing setting' do
    @provider.account_settings.create!(
      type: 'CspHeaderAdmin',
      value: "default-src 'self'"
    )

    put provider_admin_security_path, params: {
      settings: { admin_bot_protection_level: 'none' }
    }

    assert_redirected_to edit_provider_admin_security_path
    assert_nil @provider.account_settings.find_by(type: 'CspHeaderAdmin')
  end

  test 'omitting CSP header field when no setting exists does not break' do
    put provider_admin_security_path, params: {
      settings: { admin_bot_protection_level: 'none' }
    }

    assert_redirected_to edit_provider_admin_security_path
    assert_nil @provider.account_settings.find_by(type: 'CspHeaderAdmin')
  end

  test 'updates CSP report-only header setting' do
    put provider_admin_security_path, params: {
      settings: {
        admin_bot_protection_level: 'none',
        csp_report_only_header_admin: "default-src 'none'"
      }
    }

    assert_redirected_to edit_provider_admin_security_path

    @provider.reload
    setting = @provider.account_settings.find_by(type: 'CspReportOnlyHeaderAdmin')
    assert_equal "default-src 'none'", setting.value
  end

  test 'omitting CSP report-only header destroys existing setting' do
    @provider.account_settings.create!(
      type: 'CspReportOnlyHeaderAdmin',
      value: "default-src 'none'"
    )

    put provider_admin_security_path, params: {
      settings: { admin_bot_protection_level: 'none' }
    }

    assert_redirected_to edit_provider_admin_security_path
    assert_nil @provider.account_settings.find_by(type: 'CspReportOnlyHeaderAdmin')
  end

  test 'setting header to space results in header being present in response' do
    policy_value = ' '

    put provider_admin_security_path, params: {
      settings: {
        admin_bot_protection_level: 'none',
        permissions_policy_header_admin: policy_value
      }
    }

    assert_redirected_to edit_provider_admin_security_path

    @provider.reload
    setting = @provider.account_settings.find_by(type: 'PermissionsPolicyHeaderAdmin')
    assert_equal policy_value, setting.value

    # Verify the header is present in the response
    get edit_provider_admin_security_path
    assert_response :success
    assert response.headers.key?('Permissions-Policy'), 'Permissions-Policy header should be present'
  end
end
