require 'test_helper'
require 'mail'

class DasMailer < ActionMailer::Base

  def willkommen
    headers ::Message::DO_NOT_SEND_HEADER => true
    mail to: "me@#{ThreeScale.config.superdomain}", body: "DIES-IST-EIN-TEST", subject: "HELLO.", from: "me2@#{ThreeScale.config.superdomain}"
  end

  def nachrichten
    mail to: "me@#{ThreeScale.config.superdomain}", body: "DIES-IST-EIN-TEST", subject: "HELLO.", from: "me2@#{ThreeScale.config.superdomain}"
  end
end

class ThreeScale::EmailDoNotSendInterceptorTest < ActiveSupport::TestCase

  test "action mailer" do
    ActionMailer::Base.deliveries.clear

    DasMailer.willkommen.deliver_now
    DasMailer.nachrichten.deliver_now

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "mail deliver" do
    message = Mail.new(to: "me@#{ThreeScale.config.superdomain}", body: "DIES-IST-EIN-TEST", subject: "HELLO.", from: "me2@#{ThreeScale.config.superdomain}")
    message.header[::Message::DO_NOT_SEND_HEADER] = true

    ThreeScale::EmailDoNotSendInterceptor.delivering_email message

    # so, if the message would be sent, this will fail to connect to test SMTP server
    assert message.deliver
  end
end
