# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection::Checks

  class TimestampTest <  ActiveSupport::TestCase

    setup do
      @object = Object.new
      @subject = Timestamp.new(nil)
      @encryptor = ActiveSupport::MessageEncryptor.new(SPAM_CHECKS_SECRET_KEY.call)
    end

    attr_reader :subject, :object, :encryptor

    test "pass when it takes more than PERIOD for the user to fill the form" do
      value = encryptor.encrypt_and_sign((Time.now.utc - TIMESTAMP_PERIOD - 5.seconds).to_i) # The screen was printed PERIOD + 5.seconds ago
      object.stubs(:params).returns({ timestamp: value })

      result = subject.probability(object)

      assert_equal 0, result
    end

    test "computes a value when it takes less than PERIOD for the user to fill the form" do
      freeze_time do
        value = encryptor.encrypt_and_sign((Time.now.utc - 1.second).to_i)
        object.stubs(:params).returns({ timestamp: value })

        result = subject.probability(object)

        assert_equal 1 - (1.second.to_f / TIMESTAMP_PERIOD), result
      end
    end

    test "detects a bot when the given timestamp is invalid" do
      value = (Time.now.utc - TIMESTAMP_PERIOD - 5.seconds).to_i # Given value not properly encoded
      object.stubs(:params).returns({ timestamp: value })

      assert_raise ThreeScale::SpamProtection::Checks::SpamDetectedError do
        subject.probability(object)
      end
    end
  end
end
