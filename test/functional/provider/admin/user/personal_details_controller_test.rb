# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::User::PersonalDetailsControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    host! @provider.external_admin_domain
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

  test 'changing password is audited' do
    assert_difference(Audited.audit_class.method(:count)) do
      User.with_synchronous_auditing do
        put :update, params: { user: {current_password: 'supersecret', password: 'new_password', password_confirmation: 'new_password'} }
      end
    end

    expected = [Audited::Auditor::AuditedInstanceMethods::REDACTED] * 2
    assert_equal expected, @provider.first_admin.audits.last.audited_changes['password_digest']
  end

  test 'failed password change creates an audit log' do
    AuditLogService.expects(:call).with { |msg| msg.start_with? "User tried to change password" }
    put :update, params: { user: {current_password: 'wrong_password', password: 'new_password', password_confirmation: 'new_password'} }
  end

end
