require 'test_helper'

class ProviderInvitationMailerTest < ActionMailer::TestCase

  def setup
    @invitation = FactoryBot.create(:invitation)
    @account = @invitation.account
    @provider_invitation_email = ProviderInvitationMailer.invitation(@invitation)
  end

  test 'deliver' do
    @provider_invitation_email.deliver_now
    assert_equal 1, ActionMailer::Base.deliveries.count
  end

  test 'is sent to the invited provider' do
    assert_equal [@invitation.email], @provider_invitation_email.to
  end

  test 'is sent from the inviting provider' do
    assert_equal [@account.from_email], @provider_invitation_email.from
  end
end
