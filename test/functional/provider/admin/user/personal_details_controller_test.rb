# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::User::PersonalDetailsControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.external_admin_domain
    login_as @provider.admins.first
  end


  test "put update should redirect to users" do
    put :update, params: { user: {current_password: 'superSecret1234#', username: 'test', email: 'test@example.com'}, origin: 'users' }
    assert_redirected_to provider_admin_account_users_path
  end

  test "put update should redirect to edit personal details" do
    put :update, params: { user: {current_password: 'superSecret1234#', username: 'test', email: 'test@example.com'} }
    assert_redirected_to edit_provider_admin_user_personal_details_path
  end

  test  "put update should fail and render edit" do
    put :update, params: { user: {username: ''} }
    assert_response :success
    assert_template 'edit'
  end

  test 'changing password is audited' do
    assert_difference(Audited.audit_class.method(:count)) do
      User.with_synchronous_auditing do
        put :update, params: { user: {current_password: 'superSecret1234#', password: 'new_password_123', password_confirmation: 'new_password_123'} }
      end
    end

    expected = [Audited::Auditor::AuditedInstanceMethods::REDACTED] * 2
    assert_equal expected, @provider.first_admin.audits.last.audited_changes['password_digest']
  end

  test 'failed password change creates an audit log' do
    AuditLogService.expects(:call).with { |msg| msg.start_with? "User tried to change password" }
    put :update, params: { user: {current_password: 'wrong_password', password: 'new_password', password_confirmation: 'new_password'} }
  end

  class SSOUserWithoutPasswordTest < ActionController::TestCase
    tests Provider::Admin::User::PersonalDetailsController

    def setup
      @provider = FactoryBot.create(:provider_account)
      @user = @provider.admins.first
      # Simulate an SSO user: no password and has authentication_id (makes oauth2? return true)
      @user.update_columns(password_digest: nil, authentication_id: 'sso-user-id')
      host! @provider.external_admin_domain
      login_as @user
    end

    test 'edit page shows password field for SSO user without password' do
      get :edit

      assert_response :success
      assert_select 'input[name="user[password]"]'
    end

    test 'edit page does not show current password field for SSO user without password' do
      get :edit

      assert_response :success
      assert_select 'input[name="user[current_password]"]', false
    end

    test 'SSO user can set password without providing current password' do
      put :update, params: { user: { password: 'superSecret1234#', password_confirmation: 'superSecret1234#' } }

      assert_redirected_to edit_provider_admin_user_personal_details_path
      assert @user.reload.authenticated?('superSecret1234#')
    end

    test 'SSO user can update other fields without providing current password' do
      put :update, params: { user: { username: 'newusername', email: 'newemail@example.com' } }

      assert_redirected_to edit_provider_admin_user_personal_details_path
      assert_equal 'newusername', @user.reload.username
    end
  end

  class UserWithPasswordTest < ActionController::TestCase
    tests Provider::Admin::User::PersonalDetailsController

    def setup
      @provider = FactoryBot.create(:provider_account)
      @user = @provider.admins.first
      host! @provider.external_admin_domain
      login_as @user
    end

    test 'edit page shows current password field for user with password' do
      get :edit

      assert_response :success
      assert_select 'input[name="user[current_password]"]'
    end

    test 'user with password must provide current password to update' do
      put :update, params: { user: { username: 'newusername' } }

      assert_response :success
      assert_template 'edit'
      assert_match(/incorrect/i, flash[:danger])
    end

    test 'user with password can update when providing correct current password' do
      put :update, params: { user: { current_password: 'superSecret1234#', username: 'newusername' } }

      assert_redirected_to edit_provider_admin_user_personal_details_path
      assert_equal 'newusername', @user.reload.username
    end
  end

  class EnforceSSOEnabledTest < ActionController::TestCase
    tests Provider::Admin::User::PersonalDetailsController

    def setup
      @provider = FactoryBot.create(:provider_account)
      @provider.settings.update!(enforce_sso: true)
      @user = @provider.admins.first
      host! @provider.external_admin_domain
      login_as @user
    end

    test 'user can change password when enforce SSO is enabled' do
      put :update, params: { user: { current_password: 'superSecret1234#', password: 'new_password_123', password_confirmation: 'new_password_123' } }

      assert_redirected_to edit_provider_admin_user_personal_details_path
      assert @user.reload.authenticated?('new_password_123')
    end

    test 'SSO user without password can set password when enforce SSO is enabled' do
      # Simulate an SSO user: no password and has authentication_id (makes oauth2? return true)
      @user.update_columns(password_digest: nil, authentication_id: 'sso-user-id')

      put :update, params: { user: { password: 'superSecret1234#', password_confirmation: 'superSecret1234#' } }

      assert_redirected_to edit_provider_admin_user_personal_details_path
      assert @user.reload.authenticated?('superSecret1234#')
    end
  end
end
