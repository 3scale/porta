# frozen_string_literal: true

require 'test_helper'

class ThreeScale::BotProtection::BaseTest < ActiveSupport::TestCase

  class Test
    include ThreeScale::BotProtection::Base
  end

  setup do
    @account = FactoryBot.create(:buyer_account)
    @subject = Test.new.tap do |s|
      s.stubs(:site_account).returns(@account)
    end
  end
  class BotProtectionLevelTest < ThreeScale::BotProtection::BaseTest
    test 'bot_protection_level returns :none by default' do
      result = @subject.send :bot_protection_level

      assert_equal :none, result
    end

    test 'bot_protection_level takes the value from provider settings' do
      @account.settings.update(spam_protection_level: :captcha)

      result = @subject.send :bot_protection_level

      assert_equal :captcha, result
    end
  end

  class BotProtectionEnabledTest < ThreeScale::BotProtection::BaseTest
    test 'bot_protection_enabled? is false when reCaptcha is not configured' do
      Recaptcha.stubs(:captcha_configured?).returns(false)

      result = @subject.send :bot_protection_enabled?

      assert_not result
    end

    test 'bot_protection_enabled? is false when the bot protection is disabled' do
      @account.settings.update(spam_protection_level: :none)

      result = @subject.send :bot_protection_enabled?

      assert_not result
    end

    test 'bot_protection_enabled? is true when reCaptcha is configured and the bot protection is enabled' do
      Recaptcha.stubs(:captcha_configured?).returns(true)
      @account.settings.update(spam_protection_level: :captcha)

      result = @subject.send :bot_protection_enabled?

      assert result
    end
  end
end
