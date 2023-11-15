# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection
  module Integration
    class FormBuildTest < ActiveSupport::TestCase
      def subject
        @subject ||= ThreeScale::SpamProtection::Integration::FormBuilder
      end

      test "should not be included in Formtastic::FormBuilder" do
        assert_not Formtastic::FormBuilder <= subject
      end

      test "should be included in ThreeScale::SemanticFormBuilder" do
        assert ThreeScale::SemanticFormBuilder <= subject
      end
    end
  end
end
