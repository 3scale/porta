# frozen_string_literal: true

require 'test_helper'

class Sites::SecuritiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
    Rails.cache.clear
  end

  test 'edit without captcha configured shows warning' do
    Recaptcha.expects(:captcha_configured?).returns(false).twice

    get edit_admin_site_security_path

    assert_response :success
    assert_match 'reCAPTCHA has not been configured correctly', response.body
  end

  test 'edit with captcha configured shows hint' do
    Recaptcha.expects(:captcha_configured?).returns(true).twice

    get edit_admin_site_security_path

    assert_response :success
    assert_match 'reCAPTCHA v3 will invisibly verify interactions', response.body
  end

  test 'updates spam protection level setting' do
    assert_equal :none, @provider.settings.spam_protection_level

    put admin_site_security_path, params: {
      settings: {
        spam_protection_level: 'captcha'
      }
    }

    assert_redirected_to edit_admin_site_security_path
    assert_equal 'Security settings updated', flash[:success]

    @provider.settings.reload
    assert_equal :captcha, @provider.settings.spam_protection_level
  end

  test 'update spam protection with invalid value shows error' do
    put admin_site_security_path, params: {
      settings: {
        spam_protection_level: 'x' * 256
      }
    }

    assert_response :success
    assert_template :edit
    assert_equal 'There were problems saving the settings', flash[:danger]
  end

  test 'displays Permissions-Policy header field' do
    get edit_admin_site_security_path
    assert_response :success
    assert_match 'Permissions-Policy Header', response.body
  end

  test 'updates Permissions-Policy header' do
    policy_value = 'camera=(), geolocation=()'

    put admin_site_security_path, params: {
      settings: {
        spam_protection_level: 'none',
        permissions_policy_header_developer: policy_value
      }
    }

    assert_redirected_to edit_admin_site_security_path

    @provider.reload
    setting = @provider.account_settings.find_by(type: 'PermissionsPolicyHeaderDeveloper')
    assert_equal policy_value, setting.value
  end

  test 'omitting header field deletes existing setting' do
    @provider.account_settings.create!(
      type: 'PermissionsPolicyHeaderDeveloper',
      value: 'camera=()'
    )

    put admin_site_security_path, params: {
      settings: { spam_protection_level: 'none' }
    }

    assert_redirected_to edit_admin_site_security_path
    assert_nil @provider.account_settings.find_by(type: 'PermissionsPolicyHeaderDeveloper')
  end

  test 'omitting header field when no setting exists does not break' do
    put admin_site_security_path, params: {
      settings: { spam_protection_level: 'none' }
    }

    assert_redirected_to edit_admin_site_security_path
    assert_nil @provider.account_settings.find_by(type: 'PermissionsPolicyHeaderDeveloper')
  end

  test 'displays Content-Security-Policy Header field' do
    get edit_admin_site_security_path
    assert_response :success
    assert_match 'Content-Security-Policy Header', response.body
  end

  test 'updates Content-Security-Policy header' do
    csp_value = "default-src 'self'"

    put admin_site_security_path, params: {
      settings: {
        spam_protection_level: 'none',
        csp_header_developer: csp_value
      }
    }

    assert_redirected_to edit_admin_site_security_path

    @provider.reload
    setting = @provider.account_settings.find_by(type: 'CspHeaderDeveloper')
    assert_equal csp_value, setting.value
  end

  test 'updates Content-Security-Policy header to a blank value' do
    put admin_site_security_path, params: {
      settings: {
        spam_protection_level: 'none',
        csp_header_developer: ''
      }
    }

    assert_redirected_to edit_admin_site_security_path

    @provider.reload
    setting = @provider.account_settings.find_by(type: 'CspHeaderDeveloper')
    assert setting.value.blank?
  end

  test 'omitting CSP header field deletes existing setting' do
    @provider.account_settings.create!(
      type: 'CspHeaderDeveloper',
      value: "default-src 'self'"
    )

    put admin_site_security_path, params: {
      settings: { spam_protection_level: 'none' }
    }

    assert_redirected_to edit_admin_site_security_path
    assert_nil @provider.account_settings.find_by(type: 'CspHeaderDeveloper')
  end

  test 'updates CSP report-only header setting' do
    put admin_site_security_path, params: {
      settings: {
        spam_protection_level: 'none',
        csp_report_only_header_developer: "default-src 'none'"
      }
    }

    assert_redirected_to edit_admin_site_security_path

    @provider.reload
    setting = @provider.account_settings.find_by(type: 'CspReportOnlyHeaderDeveloper')
    assert_equal "default-src 'none'", setting.value
  end

  test 'requires authentication' do
    logout!

    get edit_admin_site_security_path
    assert_redirected_to provider_login_path

    put admin_site_security_path, params: {
      settings: { spam_protection_level: 'captcha' }
    }
    assert_redirected_to provider_login_path
  end

  test 'requires authorization to manage settings' do
    member = FactoryBot.create(:member, account: @provider)
    member.activate!
    logout!
    login_provider @provider, user: member

    get edit_admin_site_security_path
    assert_response :forbidden

    put admin_site_security_path, params: {
      settings: { spam_protection_level: 'captcha' }
    }
    assert_response :forbidden
  end
end
