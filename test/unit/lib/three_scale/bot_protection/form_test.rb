# frozen_string_literal: true

require 'test_helper'

class ThreeScale::BotProtection::FormTest < ActiveSupport::TestCase

  class Test
    include ThreeScale::BotProtection::Form
  end

  setup do
    @subject = Test.new.tap do |s|
      template = mock('template')
      s.stubs(:template).returns(template)
    end
  end

  class BotProtectionInputsTest < ThreeScale::BotProtection::FormTest
    test 'bot_protection_inputs returns nothing if bot protection is disabled' do
      @subject.stubs(:bot_protection_enabled?).returns(false)

      result = @subject.send :bot_protection_inputs

      assert_empty result
    end

    test 'bot_protection_inputs returns reCaptcha if bot protection is enabled' do
      @subject.stubs(:bot_protection_enabled?).returns(true)
      @subject.stubs(:controller).returns(mock('controller', controller_path: '/test'))

      result = @subject.send(:bot_protection_inputs)

      assert_match /g-recaptcha/, result
    end
  end
end
