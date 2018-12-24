require 'test_helper'

class DeveloperPortal::PasswordTokenTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:simple_provider)
    @buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)
    @user = FactoryBot.create(:user, account: @buyer)

    host! @provider.domain
  end

  def test_password_token
    get developer_portal.admin_account_password_path(password_reset_token: '123')
    assert_response :redirect

    @user.generate_lost_password_token
    get developer_portal.admin_account_password_path(password_reset_token: @user.lost_password_token)
    assert_response :success

    @user.lost_password_token_generated_at = 2.days.ago
    @user.save!
    get developer_portal.admin_account_password_path(password_reset_token: @user.lost_password_token)
    assert_response :redirect
  end

  def test_update_password
    @user.generate_lost_password_token

    put developer_portal.admin_account_password_path(user: { password: 'password123',
      password_confirmation: 'password123' }, password_reset_token: @user.lost_password_token)
    assert_match 'password has been changed', flash[:notice]

    put developer_portal.admin_account_password_path(user: { password: '123password',
      password_confirmation: '123password' }, password_reset_token: @user.lost_password_token)
    assert_match 'password reset token is invalid', flash[:error]
  end
end
