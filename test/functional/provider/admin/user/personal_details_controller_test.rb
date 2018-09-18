require 'test_helper'

class Provider::Admin::User::PersonalDetailsControllerTest < ActionController::TestCase

  def setup
    @provider = Factory(:provider_account)
    host! @provider.admin_domain
    login_as @provider.admins.first
  end


  test "put update should redirect to users" do
    put :update, user: {current_password: 'supersecret' , username: 'test', email: 'test@example.com'}, origin: 'users'
    assert_redirected_to provider_admin_account_users_path
  end

  test "put update should redirect to edit personal details" do
    put :update, user: {current_password: 'supersecret' , username: 'test', email: 'test@example.com'}
    assert_redirected_to edit_provider_admin_user_personal_details_path
  end

  test  "put update should fail and render edit" do
    put :update, user: {username: ''}
    assert_response :success
    assert_template 'edit'
  end

end
