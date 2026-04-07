require 'test_helper'

class Sites::AdminSecurityTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    # Remove default settings created by test helper
    @provider.account_settings.where(type: 'AccountSetting::PermissionsPolicyHeaderAdmin').delete_all
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
    setting = @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderAdmin')
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
end
