# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection
  class ProtectorTest < ActiveSupport::TestCase

    class Controller < ApplicationController
      include ThreeScale::SpamProtection::Integration::Controller
      has_spam_protection :timestamp, :honeypot, :javascript
    end

    setup do
      controller = Controller.new
      controller.stubs(:request).returns(ActionDispatch::Request.new({}))
      controller.instantiate_checks
      @subject = ThreeScale::SpamProtection::Protector.new(controller)
    end

    attr_reader :subject

    test "#spam_probability returns an average of check results" do
      Checks::Timestamp.any_instance.stubs(:probability).returns(0.5)
      Checks::Javascript.any_instance.stubs(:probability).returns(0)
      Checks::Honeypot.any_instance.stubs(:probability).returns(1)

      result = subject.spam_probability

      assert_equal 0.5, result
    end

    test "#spam? returns true when exceeding the threshold" do
      subject.stubs(:spam_probability).returns(SPAM_THRESHOLD - 0.1)
      assert_not subject.spam?

      subject.stubs(:spam_probability).returns(SPAM_THRESHOLD + 0.1)
      assert subject.spam?
    end
  end
end
