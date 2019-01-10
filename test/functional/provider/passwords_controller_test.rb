require 'test_helper'

class Provider::PasswordsControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @user = @provider.first_admin
    @request.host = @provider.self_domain
  end

  # This test cover the posibility of tokens without 'generate_at'
  # regression test of: https://github.com/3scale/system/issues/4197
  test 'show password with lost_password_token_generated_at' do
    @user.lost_password_token = "123"
    @user.lost_password_token_generated_at = nil
    @user.save

    get :show, password_reset_token: 123
    assert_response 302
    assert flash[:error].present?
  end

  test 'generate new token' do
    @user.update_columns(password_digest: nil)
    login_as(@user)

    get :new

    @user.reload

    assert_redirected_to action: :show, password_reset_token: @user.lost_password_token
  end

  test 'refuse to generate new token' do
    login_as(@user)

    request.env['HTTP_REFERER'] = back = 'http://example.com'

    get :new

    assert_redirected_to back
  end

end
