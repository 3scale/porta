require 'test_helper'
require 'mail'

class LeMailer < ActionMailer::Base

  def bienvenu
    headers ::Message::APPLY_ENGAGEMENT_FOOTER => true
    mail to: "me@#{ThreeScale.config.superdomain}", body: "Le test message.", subject: "HELLO.", from: "me2@#{ThreeScale.config.superdomain}"
  end

  def aurevoir
    headers ::Message::APPLY_ENGAGEMENT_FOOTER => false
    mail to: "me@#{ThreeScale.config.superdomain}", body: "Le test.", subject: "HELLO.", from: "me2@#{ThreeScale.config.superdomain}"
  end
end

class ThreeScale::EmailEngagementFooterTest < ActiveSupport::TestCase

  test "interceptor for action mailer" do
    email = LeMailer.bienvenu.deliver_now

    assert_match email.body, /3scale API/

    email = LeMailer.aurevoir.deliver_now
    assert_equal email.body, "Le test."
  end
end
