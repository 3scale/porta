# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection
  module Integration

    class TestController < ApplicationController
      include ThreeScale::SpamProtection::Integration::Controller
    end

    class ControllerTest < ActiveSupport::TestCase

      class InheritanceTest < ActiveSupport::TestCase
        def subject
          @subject ||= ThreeScale::SpamProtection::Integration::Controller
        end

        test "not be included in ApplicationController" do
          assert_not ApplicationController<= subject
        end

        test "be included in the provider signup controller" do
          assert Provider::SignupsController <= subject
        end

        test "be included in the buyer signup controller" do
          assert DeveloperPortal::SignupController <= subject
        end

        test "be included in the buyer reset password controller" do
          assert DeveloperPortal::Admin::Account::PasswordsController <= subject
        end
      end
    end

    class IntegrationTest < ActiveSupport::TestCase

      class InstanceTest < ActiveSupport::TestCase
        setup do
          @subject = TestController.new
        end

        attr_reader :subject

        test "should have right methods" do
          assert subject.respond_to?(:instantiate_checks)
          assert subject.respond_to?(:spam_protection)
          assert_not subject.respond_to?(:spam_protection=)
          assert subject.respond_to?(:spam_protection_conf)
          assert_not subject.respond_to?(:spam_protection_conf=)
        end
      end

      class ClassTest < ActiveSupport::TestCase
        setup do
          @subject = TestController
        end

        attr_reader :subject

        test "should have right methods" do
          assert subject.respond_to?(:has_spam_protection)
          assert subject.respond_to?(:enabled_checks)
        end
      end
    end

    class FormTest < ActiveSupport::TestCase
      setup do
        @subject = TestController.new
        @subject.stubs(:request).returns(ActionDispatch::Request.new({}))
      end

      attr_reader :subject

      test "#form returns a form with access to the proper store" do
        subject.store[:marked_as_possible_spam_until] = 'dummy'
        dummy = Object.new

        form = subject.spam_protection_form(dummy)

        assert_equal 'dummy', form.instance_variable_get('@store')[:marked_as_possible_spam_until]
      end
    end
  end
end
