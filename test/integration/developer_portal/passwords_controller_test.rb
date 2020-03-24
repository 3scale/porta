# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::PasswordsControllerTest < ActionDispatch::IntegrationTest

  def setup
    Recaptcha.stubs(:captcha_configured?).returns(true)
    host! provider.domain
  end

  def test_password_token
    get developer_portal.admin_account_password_path(password_reset_token: '123')
    assert_response :redirect

    user.generate_lost_password_token
    get developer_portal.admin_account_password_path(password_reset_token: user.lost_password_token)
    assert_response :success

    user.lost_password_token_generated_at = 2.days.ago
    user.save!
    get developer_portal.admin_account_password_path(password_reset_token: user.lost_password_token)
    assert_response :redirect
  end

  def test_update_password
    user.generate_lost_password_token

    put developer_portal.admin_account_password_path(user: { password: 'password123',
      password_confirmation: 'password123' }, password_reset_token: user.lost_password_token)
    assert_match 'password has been changed', flash[:notice]

    put developer_portal.admin_account_password_path(user: { password: '123password',
      password_confirmation: '123password' }, password_reset_token: user.lost_password_token)
    assert_match 'password reset token is invalid', flash[:error]
  end

  test 'captcha is present when spam security enabled' do
    provider.settings.update_attributes(spam_protection_level: :captcha)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert body.include? 'g-recaptcha'
  end

  test 'captcha is not present when spam security set to auto and it is not a spam object' do
    provider.settings.update_attributes(spam_protection_level: :auto)
    ThreeScale::SpamProtection::Protector.any_instance.stubs(spam?: false)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert_not body.include? 'g-recaptcha'
  end

  test 'captcha is present when spam security set to auto it is a spam object' do
    provider.settings.update_attributes(spam_protection_level: :auto)
    ThreeScale::SpamProtection::Protector.any_instance.stubs(spam?: true)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert body.include? 'g-recaptcha'
  end

  test 'captcha is not present when spam security disabled' do
    provider.settings.update_attributes(spam_protection_level: :none)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert_not body.include? 'g-recaptcha'
  end

  test 'create responds with error message when detects spam' do
    provider.settings.update_attributes(spam_protection_level: :auto)
    ThreeScale::SpamProtection::Protector.any_instance.stubs(spam?: true)
    Recaptcha::Verify.stubs(skip?: false)

    post developer_portal.admin_account_password_path(email: 'user@example.com')
    assert_equal 'Spam protection failed.', flash[:error]
    assert_redirected_to developer_portal.new_admin_account_password_path(request_password_reset: true)
  end

  test 'create sends the email when captcha passes and finds the email' do
    provider.settings.update_attributes(spam_protection_level: :auto)
    ThreeScale::SpamProtection::Protector.any_instance.stubs(spam?: true)
    Recaptcha::Verify.stubs(skip?: true)

    post developer_portal.admin_account_password_path(email: user.email)
    assert_equal 'A password reset link has been emailed to you.', flash[:notice]
    assert_redirected_to developer_portal.login_path
    assert user.reload.lost_password_token
    assert user.reload.lost_password_token_generated_at
  end

  test 'create renders the right error message when the email is not found' do
    provider.settings.update_attributes(spam_protection_level: :none)
    Recaptcha::Verify.stubs(skip?: false)

    post developer_portal.admin_account_password_path(email: 'fake@example.com')
    assert_equal 'Email not found.', flash[:error]
    assert_redirected_to developer_portal.new_admin_account_password_path(request_password_reset: true)
  end

  private

  def buyer
    @buyer ||= FactoryBot.create(:simple_buyer, provider_account: provider)
  end

  def user
    @user ||= FactoryBot.create(:user, account: buyer)
  end

  def provider
    @provider ||= FactoryBot.create(:simple_provider)
  end

end
