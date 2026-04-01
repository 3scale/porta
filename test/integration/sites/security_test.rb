require 'test_helper'

class Sites::SecurityTest < ActionDispatch::IntegrationTest

  setup do
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
    host! @provider.external_admin_domain
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
      settings: { spam_protection_level: 'none' },
      account_setting: { value: policy_value }
    }
    
    assert_redirected_to edit_admin_site_security_path
    
    setting = @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderDeveloper')
    assert_equal policy_value, setting.value
  end

  test 'shows Permissions-Policy header in developer portal' do
    @provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper',
      value: 'camera=(), geolocation=()'
    )
    
    buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    user = FactoryBot.create(:user, account: buyer)
    user.activate!
    
    host! @provider.internal_domain
    login_with user.username, 'superSecret1234#'
    
    get '/admin'
    assert_response :success
    assert_equal 'camera=(), geolocation=()', response.headers['Permissions-Policy']
  end

  test 'uses default (empty) Permissions-Policy for developer portal when no setting exists' do
    buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    user = FactoryBot.create(:user, account: buyer)
    user.activate!
    
    host! @provider.internal_domain
    login_with user.username, 'superSecret1234#'
    
    get '/admin'
    assert_response :success
    # Default for developer portal is empty (no restrictions)
    assert_nil response.headers['Permissions-Policy']
  end

  test 'does not set header when value is blank' do
    @provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper',
      value: ''
    )
    
    buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    user = FactoryBot.create(:user, account: buyer)
    user.activate!
    
    host! @provider.internal_domain
    login_with user.username, 'superSecret1234#'
    
    get '/admin'
    assert_response :success
    assert_nil response.headers['Permissions-Policy']
  end
end