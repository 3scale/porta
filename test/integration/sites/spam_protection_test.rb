require 'test_helper'

class Sites::SpamProtectionTest < ActionDispatch::IntegrationTest

  def setup
    provider = FactoryBot.create(:provider_account)

    login_provider provider

    host! provider.admin_domain
  end

  def test_edit
    get edit_admin_site_spam_protection_path
    assert_response :success
    assert_match 'reCAPTCHA has not been configured correctly', response.body

    Recaptcha.expects(:captcha_configured?).returns(true).at_least_once
    get edit_admin_site_spam_protection_path
    assert_response :success
    assert_not_match 'reCAPTCHA has not been configured correctly', response.body
  end
end
