# frozen_string_literal: true

require 'test_helper'

class Sites::SecurityTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
    host! @provider.external_admin_domain
    Rails.cache.clear
  end

  test 'edit without captcha' do
    Recaptcha.expects(:captcha_configured?).returns(false).twice
    get edit_admin_site_security_path
    assert_response :success
    assert_match 'reCAPTCHA has not been configured correctly', response.body
  end

  test 'edit with captcha' do
    Recaptcha.expects(:captcha_configured?).returns(true).twice
    get edit_admin_site_security_path
    assert_response :success
    assert_not_match 'reCAPTCHA has not been configured correctly', response.body
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
    setting = @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderDeveloper')
    assert_equal policy_value, setting.value
  end

  test 'omitting header field deletes existing setting' do
    @provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper',
      value: 'camera=()'
    )

    put admin_site_security_path, params: {
      settings: { spam_protection_level: 'none' }
    }

    assert_redirected_to edit_admin_site_security_path
    assert_nil @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderDeveloper')
  end

  test 'omitting header field when no setting exists does not break' do
    put admin_site_security_path, params: {
      settings: { spam_protection_level: 'none' }
    }

    assert_redirected_to edit_admin_site_security_path
    assert_nil @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderDeveloper')
  end

  test 'updates spam protection level setting' do
    put admin_site_security_path, params: {
      settings: {
        spam_protection_level: 'captcha'
      }
    }

    assert_redirected_to edit_admin_site_security_path

    @provider.settings.reload
    assert_equal :captcha, @provider.settings.spam_protection_level
  end

end
