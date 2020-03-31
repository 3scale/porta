# frozen_string_literal: true

module TestHelpers
  module SpamProtectionStubs
    def stub_spam_protection_needed
      ThreeScale::SpamProtection::Protector::FormProtector.any_instance.stubs(:captcha_needed?)
    end

    def stub_spam_protection_timestamp_probability(value)
      ThreeScale::SpamProtection::Checks::Timestamp.any_instance.stubs(:probability).returns(value)
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::SpamProtectionStubs)
