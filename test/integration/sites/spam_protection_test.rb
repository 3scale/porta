require 'test_helper'

class Sites::SpamProtectionTest < ActionDispatch::IntegrationTest

  setup do
    provider = FactoryBot.create(:provider_account)

    login_provider provider

    host! provider.external_admin_domain
  end

  test 'edit without captcha' do
    Recaptcha.expects(:captcha_configured?).returns(false).twice
    get edit_admin_site_spam_protection_path
    assert_response :success
    assert_match 'reCAPTCHA has not been configured correctly', response.body
  end

  test 'edit with captcha' do
    Recaptcha.expects(:captcha_configured?).returns(true).twice
    get edit_admin_site_spam_protection_path
    assert_response :success
    assert_not_match 'reCAPTCHA has not been configured correctly', response.body
  end
end
