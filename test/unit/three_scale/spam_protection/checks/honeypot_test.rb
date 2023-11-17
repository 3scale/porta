# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection::Checks

  class HoneypotTest <  ActiveSupport::TestCase

    setup do
      @object = Object.new
      @subject = Honeypot.new(nil)
    end

    attr_reader :subject, :object

    test "pass when the honeypot is not checked" do
      object.stubs(:params).returns({ confirmation: '0' })

      result = subject.probability(object)

      assert_equal 0, result
    end

    test "detects a bot when the honeypot is checked" do
      object.stubs(:params).returns({ confirmation: '1' })

      assert_raise ThreeScale::SpamProtection::Checks::SpamDetectedError do
        subject.probability(object)
      end
    end
  end
end
