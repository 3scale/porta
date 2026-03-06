# frozen_string_literal: true

require 'test_helper'

class Provider::InviteeSignupsControllerIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    host! provider.external_admin_domain
    @invitation = FactoryBot.create(:invitation, account: provider)
  end

  attr_reader :provider, :invitation

  test 'show' do
    get provider_invitee_signup_path(invitation_token: invitation.token)

    assert_response :success
    assert_template 'show'
  end

  test 'create' do
    FieldsDefinition.create_defaults!(provider.provider_account)
    assert_difference(provider.users.method(:count)) do
      post provider_invitee_signup_path(invitation_token: invitation.token, user: user_params)
    end

    assert_equal I18n.t('provider.invitee_signups.create.success'), flash[:success]
    assert_redirected_to provider_login_path
  end

  test 'do not set unpermitted attributes' do
    FieldsDefinition.create_defaults!(provider.provider_account)
    invitation = FactoryBot.create(:invitation, account: provider)

    assert_difference(provider.users.method(:count), +1) do
      post provider_invitee_signup_path(invitation_token: invitation.token, user: user_params.merge(
        role: 'superadmin'
      ))
    end

    assert_equal I18n.t('provider.invitee_signups.create.success'), flash[:success]
    assert_redirected_to provider_login_path

    created_user = invitation.reload.user
    assert_equal :member, created_user.role
    assert_equal 'admin', created_user.username
  end


  test 'get asks for upgrade' do
    provider.create_provider_constraints!(max_users: 0)

    post provider_invitee_signup_path(invitation_token: invitation.token, user: user_params)

    assert_response :success
    assert_template 'ask_for_upgrade'
  end

  test 'show asks for upgrade' do
    provider.create_provider_constraints!(max_users: 0)

    get provider_invitee_signup_path(invitation_token: invitation.token)

    assert_response :success
    assert_template 'ask_for_upgrade'
  end

  test 'show when not found invitation' do
    get provider_invitee_signup_path(invitation_token: 'invalid')

    assert_response :not_found
  end

  test 'show redirects out logged in users' do
    login! provider

    get provider_invitee_signup_path(invitation_token: 'abc123')

    assert_equal I18n.t('provider.invitee_signups.already_logged_in'), flash[:info]
    assert_redirected_to provider_admin_dashboard_url
  end

  private

  def user_params
    { username: 'admin', password: 'supersecret' }
  end
end
