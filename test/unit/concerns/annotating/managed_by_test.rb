# frozen_string_literal: true

require 'test_helper'

module Annotating
  class ManagedByTest < ActiveSupport::TestCase
    class AnnotatedFeature< Feature
      annotated
    end

    test "#managed_by returns the value of the 'managed' annotation" do
      value = 'operator'
      subject = AnnotatedFeature.new
      subject.annotate('managed', value)

      result = subject.managed_by

      assert_equal value, result
    end

    test "#managed_by returns nil when the 'managed' annotation doesn't exist" do
      subject = AnnotatedFeature.new

      result = subject.managed_by

      assert_nil result
    end

    test "#managed_by= sets the 'managed' annotation" do
      value = 'operator'
      subject = AnnotatedFeature.new

      subject.managed_by = value

      assert_equal value, subject.value_of_annotation('managed')
    end
  end
end
