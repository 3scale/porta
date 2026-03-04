# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Accounts::InviteeSignupsControllerTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

  def setup
    @buyer = FactoryBot.create(:buyer_account)
    host! buyer.provider_account.internal_domain
  end

  attr_reader :buyer

  test 'show redirects out logged in users' do
    login_buyer buyer

    get invitee_signup_path(invitation_token: 'abc123')

    assert_redirected_to admin_dashboard_path
  end

  test 'show when not found invitation, redirects to login path with the invitation_not_found flash error message' do
    get invitee_signup_path(invitation_token: 'invalid')

    assert_equal I18n.t('errors.messages.invitation_not_found'), flash[:error]
    assert_redirected_to login_path
  end

  test 'show when invitation belongs to a different provider, redirects to login path with the invitation_not_found flash error message' do
    invitation = FactoryBot.create(:invitation)

    get invitee_signup_path(invitation_token: invitation.token)

    assert_equal I18n.t('errors.messages.invitation_not_found'), flash[:error]
    assert_redirected_to login_path
  end

  test 'create with user successfully activated' do
    invitation = FactoryBot.create(:invitation, account: buyer)

    assert_difference(buyer.users.method(:count), +1) do
      post invitee_signup_path(invitation_token: invitation.token, user: user_params)
    end

    assert_equal I18n.t('developer_portal.accounts.invitee_signups.create.success'), flash[:notice]
    assert_redirected_to login_path
  end

  test 'create pushes webhook' do
    invitation = FactoryBot.create(:invitation, account: buyer)

    WebHook::Event.expects(:enqueue).times(1)

    post invitee_signup_path(invitation_token: invitation.token, user: user_params)
  end

  test 'create redirects out for already accepted invitations' do
    invitation = FactoryBot.create(:invitation, account: buyer)
    invitation.accept!

    post invitee_signup_path(invitation_token: invitation.token, user: user_params)

    assert_equal I18n.t('errors.messages.invitation_already_accepted'), flash[:error]
    assert_redirected_to login_path
  end

  private

  def user_params
    { username: 'admin', password: 'superSecret1234#' }
  end
end
