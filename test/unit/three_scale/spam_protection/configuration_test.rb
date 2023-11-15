# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection
  class ConfigurationTest < ActiveSupport::TestCase
    setup do
      dummy = Object.new
      dummy.stubs(:store).returns({})
      @subject = ThreeScale::SpamProtection::Configuration.new(dummy)
      @subject.enable_checks! %i[honeypot timestamp]
    end

    attr_reader :subject

    test "should have have right allowed checks" do
      assert_equal %i[honeypot timestamp], subject.enabled_checks
    end

    test "should have #enabled? check" do
      assert subject.enabled?(:honeypot)
      assert subject.enabled?(:timestamp)
      assert_not subject.enabled?(:javascript)
    end

    test "checks are correctly instantiated" do
      assert_equal ThreeScale::SpamProtection::Checks::Honeypot, subject.check(:honeypot).class
      assert_equal ThreeScale::SpamProtection::Checks::Timestamp, subject.check(:timestamp).class
    end
  end
end
