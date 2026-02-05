# frozen_string_literal: true

require 'test_helper'

class Provider::PasswordsControllerIntegrationTest < ActionDispatch::IntegrationTest

  class WithProviderUserTest < Provider::PasswordsControllerIntegrationTest
    def setup
      @user = FactoryBot.create(:simple_user)

      host! @user.account.internal_admin_domain
    end

    def test_user_reset_his_password
      # user requests for a forgotten password email
      delete provider_password_path(email: @user.email)
      assert_response :redirect
      assert_match "We sent an email with password reset instructions to: #{@user.email}", flash[:success]

      # user opens forgotten password page with a password reset token parameter
      email_token = @user.reload.lost_password_token
      assert_nil session[:password_reset_token]
      get provider_password_path(password_reset_token: email_token)
      # new token is being generated and stored in a session
      assert_response :redirect
      regenerated_token = @user.reload.lost_password_token
      assert_not_equal email_token, regenerated_token
      assert_equal session[:password_reset_token], regenerated_token

      # new token is not being generated, it just renders :show
      get provider_password_path(password_reset_token: '12345')
      assert_response :success
      assert_equal session[:password_reset_token], regenerated_token

      # user updates his password
      put provider_password_path(user: { password: 'new_password_123',password_confirmation: 'new_password_123' })
      assert_response :redirect
      assert_match 'password has been changed', flash[:success]
      assert_nil session[:password_reset_token]

      # user is unable to open forgotten password page again (missing parameter)
      get provider_password_path
      assert_response 400
      # user is unable to open forgotten password page again (invalid token)
      assert_nil @user.reload.lost_password_token
      get provider_password_path(password_reset_token: email_token)
      assert_response :redirect
      assert_match 'password reset token is invalid', flash[:danger]
      get provider_password_path(password_reset_token: regenerated_token)
      assert_response :redirect
      assert_match 'password reset token is invalid', flash[:danger]
    end
  end

  class WithMasterUserTest < Provider::PasswordsControllerIntegrationTest
    test '#destroy does not work for master account' do
      login_provider master_account

      assert_raise(ActionController::RoutingError) { delete provider_password_path, params: { email: 'example@test.com' } }
    end
  end
end
