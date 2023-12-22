# frozen_string_literal: true

require 'test_helper'

class ThreeScale::BotProtection::ControllerTest < ActiveSupport::TestCase

  class Test
    include ThreeScale::BotProtection::Controller
  end

  setup do
    @subject = Test.new.tap do |s|
      s.stubs(:controller_path).returns('/test')
      s.stubs(:flash).returns({})
    end
    Recaptcha.stubs(:captcha_configured?).returns(true)
  end

  class VerifyCaptchaTest < ThreeScale::BotProtection::ControllerTest
    test 'verify_captcha returns true when reCaptcha succeeds' do
      @subject.stubs(:verify_recaptcha).returns(true)

      result = @subject.send :verify_captcha, {}

      assert result
    end

    test 'verify_captcha returns false when reCaptcha fails' do
      @subject.stubs(:verify_recaptcha).returns(false)

      result = @subject.send :verify_captcha, {}

      assert_not result
    end
  end

  class BotCheckTest < ThreeScale::BotProtection::ControllerTest
    test 'spam_check is true when bot protection is disabled' do
      @subject.stubs(:bot_protection_level).returns(:none)

      result = @subject.send :bot_check

      assert result
    end

    test 'spam_check is true when the bot protection is enabled and the reCaptcha challenge succeeds' do
      @subject.stubs(:bot_protection_level).returns(:captcha)
      @subject.stubs(:verify_captcha).returns(true)

      result = @subject.send :bot_check

      assert result
    end

    test 'spam_check is false when the bot protection is enabled and the reCaptcha challenge fails' do
      @subject.stubs(:bot_protection_level).returns(:captcha)
      @subject.stubs(:verify_captcha).returns(false)

      result = @subject.send :bot_check

      assert_not result
    end
  end
end
