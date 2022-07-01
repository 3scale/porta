# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::User::PersonalDetailsControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.internal_admin_domain
    login_as @provider.admins.first
  end


  test "put update should redirect to users" do
    put :update, params: { user: {current_password: 'supersecret', username: 'test', email: 'test@example.com'}, origin: 'users' }
    assert_redirected_to provider_admin_account_users_path
  end

  test "put update should redirect to edit personal details" do
    put :update, params: { user: {current_password: 'supersecret', username: 'test', email: 'test@example.com'} }
    assert_redirected_to edit_provider_admin_user_personal_details_path
  end

  test  "put update should fail and render edit" do
    put :update, params: { user: {username: ''} }
    assert_response :success
    assert_template 'edit'
  end

end
