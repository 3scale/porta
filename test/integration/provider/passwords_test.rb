require 'test_helper'

class Provider::PasswordsControllerTest < ActionDispatch::IntegrationTest

  class WithProviderUserTest < Provider::PasswordsControllerTest
    def setup
      @user = FactoryBot.create(:simple_user)

      host! @user.account.self_domain
    end

    def test_user_reset_his_password
      # user requests for a forgotten password email
      delete provider_password_path(email: @user.email)
      assert_response :redirect
      assert_match 'password reset link has been emailed', flash[:notice]

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
      put provider_password_path(user: { password: 'alaska123',password_confirmation: 'alaska123' })
      assert_response :redirect
      assert_match 'password has been changed', flash[:notice]
      assert_nil session[:password_reset_token]

      # user is unable to open forgotten password page again (missing parameter)
      get provider_password_path
      assert_response 400
      # user is unable to open forgotten password page again (invalid token)
      assert_nil @user.reload.lost_password_token
      get provider_password_path(password_reset_token: email_token)
      assert_response :redirect
      assert_match 'password reset token is invalid', flash[:error]
      get provider_password_path(password_reset_token: regenerated_token)
      assert_response :redirect
      assert_match 'password reset token is invalid', flash[:error]
    end
  end

  class WithMasterUserTest < Provider::PasswordsControllerTest
    test '#destroy does not work for master account' do
      login_provider master_account

      assert_raise(ActionController::RoutingError) { delete provider_password_path, email: 'example@test.com' }
    end
  end
end
