require 'test_helper'
require 'mail'

class ThreeScale::EmailConfigurationInterceptorTest < ActiveSupport::TestCase
  class SimpleMailer < ActionMailer::Base
    def simple_message(from)
      mail to: "me@#{ThreeScale.config.superdomain}", body: "DIES-IST-EIN-TEST", subject: "HELLO.", from: from
    end
  end

  setup do
    Features::EmailConfigurationConfig.stubs(enabled?: true)
    @email_configuration = FactoryBot.create(:email_configuration)
    @message = SimpleMailer.simple_message(@email_configuration.email)
  end

  test "should intercept messages" do
    ActionMailer::Base.deliveries.clear
    ThreeScale::EmailConfigurationInterceptor.expects(:delivering_email).with(@message).once

    @message.deliver_now

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "should set email delivery settings" do
    ThreeScale::EmailConfigurationInterceptor.delivering_email @message

    assert_equal @email_configuration.smtp_settings, @message.delivery_method.settings
    assert @message.perform_deliveries
  end

  test "should not set delivery settings when email does not match" do
    @message = SimpleMailer.simple_message("me@#{ThreeScale.config.superdomain}")
    ThreeScale::EmailConfigurationInterceptor.delivering_email @message

    assert_not_equal @email_configuration.smtp_settings, @message.delivery_method.settings
    assert @message.perform_deliveries
  end

  test "should not set delivery settings when disabled" do
    Features::EmailConfigurationConfig.stubs(enabled?: false)
    ThreeScale::EmailConfigurationInterceptor.delivering_email @message

    assert_not_equal @email_configuration.smtp_settings, @message.delivery_method.settings
    assert @message.perform_deliveries
  end
end
