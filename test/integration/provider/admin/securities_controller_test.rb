# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::SecuritiesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
    Rails.cache.clear
  end

  test 'edit without captcha configured shows warning' do
    Recaptcha.expects(:captcha_configured?).returns(false).twice

    get edit_provider_admin_security_path

    assert_response :success
    assert_match 'reCAPTCHA has not been configured correctly', response.body
  end

  test 'edit with captcha configured shows hint' do
    Recaptcha.expects(:captcha_configured?).returns(true).twice

    get edit_provider_admin_security_path

    assert_response :success
    assert_match 'reCAPTCHA v3 will invisibly verify interactions', response.body
  end

  test 'updates admin bot protection level setting' do
    assert_equal :none, @provider.settings.admin_bot_protection_level

    put provider_admin_security_path, params: {
      settings: {
        admin_bot_protection_level: 'captcha'
      }
    }

    assert_redirected_to edit_provider_admin_security_path
    assert_equal 'Security settings updated', flash[:success]

    @provider.settings.reload
    assert_equal :captcha, @provider.settings.admin_bot_protection_level
  end

  test 'update with invalid value shows error' do
    put provider_admin_security_path, params: {
      settings: {
        admin_bot_protection_level: 'x' * 256
      }
    }

    assert_response :success
    assert_template :edit
    assert_equal 'There were problems saving the settings', flash[:danger]
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
    setting = @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderAdmin')
    assert_equal policy_value, setting.value
  end

  test 'omitting header field deletes existing setting' do
    @provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderAdmin',
      value: 'camera=()'
    )

    # Submit without permissions_policy_header_admin param (checkbox unchecked)
    put provider_admin_security_path, params: {
      settings: { admin_bot_protection_level: 'none' }
    }

    assert_redirected_to edit_provider_admin_security_path
    assert_nil @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderAdmin')
  end

  test 'omitting header field when no setting exists does not break' do
    put provider_admin_security_path, params: {
      settings: { admin_bot_protection_level: 'none' }
    }

    assert_redirected_to edit_provider_admin_security_path
    assert_nil @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderAdmin')
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
    setting = @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderAdmin')
    assert_equal policy_value, setting.value

    # Verify the header is present in the response
    get edit_provider_admin_security_path
    assert_response :success
    assert response.headers.key?('Permissions-Policy'), 'Permissions-Policy header should be present'
  end

  test 'requires authentication' do
    logout!

    get edit_provider_admin_security_path
    assert_redirected_to provider_login_path

    put provider_admin_security_path, params: {
      settings: { admin_bot_protection_level: 'captcha' }
    }
    assert_redirected_to provider_login_path
  end

  test 'member can update the settings' do
    member = FactoryBot.create(:member, account: @provider)
    member.activate!
    logout!
    login_provider @provider, user: member

    get edit_provider_admin_security_path
    assert_response :success

    put provider_admin_security_path, params: {
      settings: { admin_bot_protection_level: 'captcha' }
    }

    assert_redirected_to edit_provider_admin_security_url
    assert_equal 'Security settings updated', flash[:success]
  end
end
