# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::PasswordsControllerTest < ActionDispatch::IntegrationTest

  def setup
    Recaptcha.stubs(:captcha_configured?).returns(true)
    host! provider.internal_domain
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

    put developer_portal.admin_account_password_path(user: { password: 'new_password_123',
      password_confirmation: 'new_password_123' }, password_reset_token: user.lost_password_token)
    assert_match 'password has been changed', flash[:notice]

    put developer_portal.admin_account_password_path(user: { password: '123_new_password',
      password_confirmation: '123_new_password' }, password_reset_token: user.lost_password_token)
    assert_match 'password reset token is invalid', flash[:error]
  end

  test 'captcha is present when spam security enabled' do
    provider.settings.update(spam_protection_level: :captcha)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert body.include? 'g-recaptcha'
  end

  test 'captcha is present when the removed suspicious only mode remains enabled' do
    provider.settings.update(spam_protection_level: :auto)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert body.include? 'g-recaptcha'
  end

  test 'captcha is not present when spam security disabled' do
    provider.settings.update(spam_protection_level: :none)

    get developer_portal.new_admin_account_password_path
    assert_response :success
    assert_not body.include? 'g-recaptcha'
  end

  test 'create responds with error message when detects spam' do
    provider.settings.update(spam_protection_level: :auto)
    DeveloperPortal::Admin::Account::PasswordsController.any_instance.stubs(verify_captcha: false)

    post developer_portal.admin_account_password_path(email: 'user@example.com')
    assert_equal 'Bot protection failed.', flash[:error]
    assert_redirected_to developer_portal.new_admin_account_password_path(request_password_reset: true)
  end

  test 'create sends the email when captcha passes and finds the email' do
    provider.settings.update(spam_protection_level: :auto)
    DeveloperPortal::Admin::Account::PasswordsController.any_instance.stubs(verify_captcha: true)

    UserMailer.expects(:lost_password).returns(mock('mail', deliver_later: true)).once

    assert_change of: lambda { user.reload.lost_password_token.present? }, from: false, to: true do
      post developer_portal.admin_account_password_path(email: user.email)
    end
    assert_in_delta Time.now, user.reload.lost_password_token_generated_at, 2.seconds
    assert_equal "A password reset link will be sent to #{user.email} if a user exists with this email.", flash[:notice]
    assert_redirected_to developer_portal.login_path
  end

  test 'create renders the right error message when the email is not found' do
    post developer_portal.admin_account_password_path(email: 'fake@example.com')
    assert_equal "A password reset link will be sent to fake@example.com if a user exists with this email.", flash[:notice]
    assert_redirected_to developer_portal.login_path
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
