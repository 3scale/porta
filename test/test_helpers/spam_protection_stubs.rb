module TestHelpers
  module SpamProtectionStubs

    def self.included(base)
      base.teardown(:clear_spam_protection_stubs)
    end

    def stub_spam_protection_needed
      ThreeScale::SpamProtection::Protector::FormProtector.any_instance.stubs(:captcha_needed?)
    end


    def stub_spam_protection_timestamp_probability(value)
      ThreeScale::SpamProtection::Checks::Timestamp.any_instance.stubs(:probability).returns(value)
    end

    # unstubs

    def unstub_spam_protection_needed

    end

    def clear_spam_protection_stubs
      unstub_spam_protection_needed
    end

  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::SpamProtectionStubs)
