require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  def setup
    @invitation = Factory(:invitation)
    @email      = InvitationMailer.invitation(@invitation)
  end

  test 'subject contains product name' do
    assert_equal "Invitation to join #{@invitation.account.org_name}", @email.subject
  end

  test 'is sent to the invitee' do
    assert_equal [@invitation.email], @email.to
  end

  context 'provider invitation' do
    should 'body contains signup link to admin domain of the inviting provider' do
      account = @invitation.account

      assert_match("https://#{account.admin_domain}/signup/#{@invitation.token}", @email.body.to_s)
      assert_match(@invitation.account.org_name, @email.body.to_s)
    end
  end

  test 'buyer invitation contains signup link to public domain of the provider' do
    buyer = Factory :buyer_account
    buyer_invitation = Factory(:invitation, :account => buyer)
    buyer_email      = InvitationMailer.invitation(buyer_invitation)

    assert_match("https://#{buyer.provider_account.domain}/signup/#{buyer_invitation.token}", buyer_email.body.to_s)
  end

  # TODO: is sent from ...
end
