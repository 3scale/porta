# frozen_string_literal: true

require 'test_helper'

class SendUserInvitationWorkerTest < ActiveJob::TestCase
  def test_provider_mailer_perform
    ProviderInvitationMailer.any_instance.expects(:invitation).once

    provider_account = FactoryBot.create(:provider_account)
    invitation = FactoryBot.create(:invitation, account: provider_account)

    assert_nil invitation.sent_at
    SendUserInvitationWorker.new.perform(invitation.id)
    assert invitation.reload.sent_at
  end

  def test_buyer_mailer_perform
    InvitationMailer.any_instance.expects(:invitation).once

    buyer_account = FactoryBot.create(:buyer_account)
    invitation = FactoryBot.create(:invitation, account: buyer_account)

    assert_nil invitation.sent_at
    SendUserInvitationWorker.new.perform(invitation.id)
    assert invitation.reload.sent_at
  end

  def test_perform_ssl_error
    ProviderInvitationMailer.any_instance.expects(:invitation).raises(OpenSSL::SSL::SSLError)

    invitation = FactoryBot.create(:invitation)

    assert_nil invitation.sent_at
    SendUserInvitationWorker.new.perform(invitation.id)
    assert_nil invitation.reload.sent_at
  end

  def test_handles_smpt_error
    ProviderInvitationMailer.any_instance.expects(:invitation).raises(Net::SMTPAuthenticationError)

    invitation = FactoryBot.create(:invitation)

    assert_nil invitation.sent_at
    SendUserInvitationWorker.new.perform(invitation.id)
    assert_nil invitation.reload.sent_at
  end

  def test_handles_socket_error
    ProviderInvitationMailer.any_instance.expects(:invitation).raises(SocketError)

    invitation = FactoryBot.create(:invitation)

    assert_nil invitation.sent_at
    SendUserInvitationWorker.new.perform(invitation.id)
    assert_nil invitation.reload.sent_at
  end

  def test_handles_not_found_error
    ProviderInvitationMailer.any_instance.expects(:invitation).raises(ActiveRecord::RecordNotFound)

    invitation = FactoryBot.create(:invitation)

    assert_nil invitation.sent_at
    SendUserInvitationWorker.new.perform(invitation.id)
    assert_nil invitation.reload.sent_at
  end
end
