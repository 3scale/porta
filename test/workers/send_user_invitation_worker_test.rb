# frozen_string_literal: true

require 'test_helper'

class SendUserInvitationWorkerTest < ActiveJob::TestCase
  def test_provider_mailer_perform
    travel_to(Time.zone.parse('2017-11-23 03:25:08 UTC +00:00')) do
      ProviderInvitationMailer.any_instance.expects(:invitation).once

      provider_account = FactoryBot.create(:provider_account)
      invitation = FactoryBot.create(:invitation, account: provider_account)

      assert_not invitation.sent_at
      SendUserInvitationWorker.new.perform(invitation)
      assert_in_delta Time.zone.now, invitation.reload.sent_at, 1.second
    end
  end

  def test_buyer_mailer_perform
    travel_to(Time.zone.parse('2017-11-23 03:25:08 UTC +00:00')) do
      InvitationMailer.any_instance.expects(:invitation).once

      buyer_account = FactoryBot.create(:buyer_account)
      invitation = FactoryBot.create(:invitation, account: buyer_account)

      assert_not invitation.sent_at
      SendUserInvitationWorker.new.perform(invitation)
      assert_in_delta Time.zone.now, invitation.reload.sent_at, 1.second
    end
  end

  def test_handles_errors
    SendUserInvitationWorker::RETRY_ERRORS.each do |error_class|
      ProviderInvitationMailer.any_instance.expects(:invitation).raises(error_class)

      invitation = FactoryBot.create(:invitation)

      assert_not invitation.sent_at
      worker = SendUserInvitationWorker.new
      worker.expects(:retry_job)
      worker.perform(invitation)
      assert_not invitation.reload.sent_at
    end
  end

  def test_no_invitation_in_db
    invitation = FactoryBot.create(:invitation)
    expected_log_message = /SendUserInvitationWorker#perform raised ActiveJob::DeserializationError/
    Rails.logger.expects(:error).with { |message| message.match(expected_log_message) }

    invitation.delete
    perform_enqueued_jobs(only: SendUserInvitationWorker) { SendUserInvitationWorker.perform_later(invitation) }
  end

  # regression test for: https://github.com/3scale/system/pull/3316
  def test_send_invitation_with_helper_tag
    provider = FactoryBot.create(:simple_provider)
    FactoryBot.create(:simple_buyer, provider_account: provider)
    FactoryBot.create(:cms_email_template, system_name: 'invitation', provider: provider, published: '{% debug:help %}', rails_view_path: 'emails/invitation')
    invitation = FactoryBot.create(:invitation)

    assert_difference('ActionMailer::Base.deliveries.count') do
      SendUserInvitationWorker.new.perform(invitation)
    end
  end
end
