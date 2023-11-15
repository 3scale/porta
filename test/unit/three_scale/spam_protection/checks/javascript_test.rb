# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection::Checks

  class JavascriptTest <  ActiveSupport::TestCase

    setup do
      @object = Object.new
      @subject = Javascript.new(nil)
    end

    attr_reader :subject, :object

    test "pass when the javascript is enabled" do
      object.stubs(:params).returns({ javascript: '1' })

      result = subject.probability(object)

      assert_equal 0, result
    end

    test "fails when javascript is disabled" do
      object.stubs(:params).returns({ javascript: '0' })

      result = subject.probability(object)

      assert_equal 0.6, result
    end
  end
end
