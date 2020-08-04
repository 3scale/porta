# frozen_string_literal: true

require 'test_helper'

class ThreeScale::InvitationEmailDeliveryObserverTest < ActiveSupport::TestCase
  # include ActionMailer::TestHelper

  def setup
    # InvitationMailer.register_observer ThreeScale::InvitationEmailDeliveryObserver
  end

  def test_update_date_after_sent_only
    # assert_no_emails do
      invitation = FactoryBot.create(:invitation)
      mailer = nil

      date = Date.parse('2019-09-01')
      Timecop.freeze(date) do
      #   perform_enqueued_jobs do
      #     mailer     = InvitationMailer.invitation(@invitation)
          assert_nil invitation.sent_at
      #   end
      end
    # end

    # assert_emails 0 do
    #   invitation.expects(:update_column).once

    #   Invitation.expects(find_by).once.return(invitation)

    #   assert_nil invitation.sent_at
    # end

    # assert_emails 1 do
    #   @mailer.deliver_now
    # end
  end

end
