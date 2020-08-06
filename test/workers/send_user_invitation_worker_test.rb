# frozen_string_literal: true

require 'test_helper'

class SendUserInvitationWorkerTest < ActiveJob::TestCase
  def test_provider_mailer_perform
    Timecop.freeze(Time.zone.parse('2017-11-23 03:25:08 UTC +00:00')) do
      ProviderInvitationMailer.any_instance.expects(:invitation).once

      provider_account = FactoryBot.create(:provider_account)
      invitation = FactoryBot.create(:invitation, account: provider_account)

      assert_not invitation.sent_at
      SendUserInvitationWorker.new.perform(invitation.id)
      assert_in_delta Time.zone.now, invitation.reload.sent_at, 1.second
    end
  end

  def test_buyer_mailer_perform
    Timecop.freeze(Time.zone.parse('2017-11-23 03:25:08 UTC +00:00')) do
      InvitationMailer.any_instance.expects(:invitation).once

      buyer_account = FactoryBot.create(:buyer_account)
      invitation = FactoryBot.create(:invitation, account: buyer_account)

      assert_not invitation.sent_at
      SendUserInvitationWorker.new.perform(invitation.id)
      assert_in_delta Time.zone.now, invitation.reload.sent_at, 1.second
    end
  end

  def test_handles_errors
    errors = SendUserInvitationWorker::RETRY_ERRORS + SendUserInvitationWorker::DISCARD_ERRORS
    errors.each do |error_class|
      ProviderInvitationMailer.any_instance.expects(:invitation).raises(error_class)

      invitation = FactoryBot.create(:invitation)

      assert_not invitation.sent_at
      SendUserInvitationWorker.new.perform(invitation.id)
      assert_not invitation.reload.sent_at, error_class.to_s
    end
  end

  # regression test for: https://github.com/3scale/system/pull/3316
  def test_send_invitation_with_helper_tag
    provider = FactoryBot.create(:simple_provider)
    buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
    FactoryBot.create(:cms_email_template, system_name: 'invitation', provider: provider, published: '{% debug:help %}', rails_view_path: 'emails/invitation')
    invitation = FactoryBot.create(:invitation)

    assert_difference('ActionMailer::Base.deliveries.count') do
      SendUserInvitationWorker.new.perform(invitation.id)
    end
  end
end
