# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::PasswordTokenTest < ActionDispatch::IntegrationTest

  def setup
    Recaptcha.stubs(:captcha_configured?).returns(true)
    @provider = FactoryBot.create(:simple_provider)

    host! @provider.domain
  end

  test 'captcha is present when spam security enabled' do
    @provider.settings.update_attributes(spam_protection_level: :captcha)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert body.include? 'g-recaptcha'
  end

  test 'captcha is not present when spam security set to auto' do
    @provider.settings.update_attributes(spam_protection_level: :auto)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert_not body.include? 'g-recaptcha'
  end

  test 'captcha is not present when spam security disabled' do
    @provider.settings.update_attributes(spam_protection_level: :none)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert_not body.include? 'g-recaptcha'
  end
end
