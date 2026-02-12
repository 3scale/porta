# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Admin::Account::PersonalDetailsControllerTest < DeveloperPortal::ActionController::TestCase
  def setup
    super
    @provider = FactoryBot.create(:provider_account)
    host! @provider.external_domain
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
  end

  test 'no access granted for provider admin' do
    # now exists other routes in provider side
    host! @provider.external_admin_domain

    login_as @provider.admins.first
    get :show

    assert_response 404
  end

  test 'no access granted for provider members' do
    # now exists other routes in provider side
    host! @provider.external_admin_domain

    provider_member = FactoryBot.create(:active_user, account: @provider)
    assert provider_member.member?

    login_as provider_member
    get :show

    assert_response 404
  end

  test 'grant access to admin' do
    login_as @buyer.admins.first
    get :show

    assert_response :success
  end

  test 'grant access to member' do
    buyer_member = FactoryBot.create(:active_user, account: @buyer)
    assert buyer_member.member?

    login_as buyer_member
    get :show

    assert_response :success
  end

  test 'update should succeed with current password' do
    login_as @buyer.admins.first
    put :update, params: { user: {current_password: 'superSecret1234#', username: 'test', email: 'test@example.com'}}
    assert_redirected_to admin_account_users_path
    assert_equal flash[:notice], 'User was successfully updated.'
  end

  test 'update should fail without current password' do
    login_as @buyer.admins.first
    put :update, params: { user: {username: 'test', email: 'test@example.com'}}
    assert_response :success
    assert_equal flash[:error], 'Current password is incorrect'
  end

  test 'changing password is audited' do
    user = @buyer.admins.first
    login_as user

    assert_difference(Audited.audit_class.method(:count)) do
      User.with_synchronous_auditing do
        put :update, params: { user: {current_password: 'superSecret1234#', password: 'new_password_123', password_confirmation: 'new_password_123'} }
      end
    end

    expected = [Audited::Auditor::AuditedInstanceMethods::REDACTED] * 2
    assert_equal expected,user.audits.last.audited_changes['password_digest']
  end

  test 'failed password change creates an audit log' do
    login_as @buyer.admins.first
    AuditLogService.expects(:call).with { |msg| msg.start_with? "User tried to change password" }
    put :update, params: { user: {current_password: 'wrong_password', password: 'new_password', password_confirmation: 'new_password'} }
  end
end
