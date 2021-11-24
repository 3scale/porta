# frozen_string_literal: true

require 'test_helper'

class ThreeScale::SpamProtectionTest < ActiveSupport::TestCase
  class Javascript
    include ThreeScale::SpamProtection::Integration::Model
    has_spam_protection :javascript
  end

  class Honeypot
    include ThreeScale::SpamProtection::Integration::Model
    has_spam_protection :honeypot
  end

  class Timestamp
    include ThreeScale::SpamProtection::Integration::Model
    has_spam_protection :timestamp
  end

  class EmptyTest < ActiveSupport::TestCase
    class Empty
      include ThreeScale::SpamProtection::Integration::Model
    end

    test "empty Model should have no spam protection" do
      assert Empty.spam_protection.nil?
    end
  end

  class ModelTest < ActiveSupport::TestCase
    def subject
      @subject ||= ThreeScale::SpamProtection::Integration::Model
    end

    test "not be included in ActiveRecord::Base" do
      assert_not ActiveRecord::Base <= subject
    end

    test "be included in Account" do
      assert Account <= subject
    end

    test "be included in Post" do
      assert Account <= subject
    end

    test "be included in Topic" do
      assert Account <= subject
    end
  end

  class ControllerTest < ActiveSupport::TestCase
    def subject
      @subject ||= ThreeScale::SpamProtection::Integration::Controller
    end

    test "should not be included in ActionController::Base" do
      assert_not ActionController::Base <= subject
    end

    test "should be included in NewSignupsController" do
      assert DeveloperPortal::SignupController <= subject
    end
  end

  class FormBuildTest < ActiveSupport::TestCase
    def subject
      @subject ||= ThreeScale::SpamProtection::Integration::FormBuilder
    end

    test "should not be included in Formtastic::SemanticFormBuilder" do
      assert_not Formtastic::SemanticFormBuilder <= subject
    end

    test "should be included in ThreeScale::SemanticFormBuilder" do
      assert ThreeScale::SemanticFormBuilder <= subject
    end
  end

  class FakeModelTest < ActiveSupport::TestCase
    class Model
      include ThreeScale::SpamProtection::Integration::Model
      has_spam_protection :honeypot, :timestamp
    end

    teardown do
      @subject = nil
    end

    class ClassTest < FakeModelTest
      def subject
        @subject ||= Model
      end

      test "should have right methods" do
        assert subject.respond_to?(:spam_protection)
        assert_not subject.respond_to?(:spam_protection=)
      end
    end

    class ConfigurationTest < FakeModelTest
      def subject
        @subject ||= Model.spam_protection
      end

      test "should have have right allowed checks" do
        assert_equal %i[honeypot timestamp], subject.enabled_checks
      end

      test "should have #enabled? check" do
        assert subject.enabled?(:honeypot)
        assert subject.enabled?(:timestamp)
        assert_not subject.enabled?(:javascript)
      end
    end

    class InstanceTest < FakeModelTest
      def subject
        @subject ||= Model.new
      end

      test "should have right methods" do
        method = subject.method(:spam_protection)
        assert method
        assert_equal 0, method.arity
      end

      test "should have spam level" do
        assert_equal 0.4, subject.spam_protection.spam_level
      end
    end

    class TimestampTest < FakeModelTest
      def subject
        @subject ||= Timestamp.new
      end

      test "validate" do
        subject.timestamp = 1.second.ago
        assert subject.spam?

        # cannot pass plaintext string
        subject.timestamp = 10.seconds.ago.to_f.to_s
        assert_equal 1, subject.spam_probability

        Timecop.freeze do
          check = subject.spam_protection.check(:timestamp)
          subject.timestamp = check.encode(5.seconds.ago.to_f)
          assert_equal 0.5, subject.spam_probability.round(2)
          assert subject.spam?
        end
      end
    end

    class FormProtectionTest < FakeModelTest
      def subject
        @subject ||= @object.spam_protection.form(@form)
      end

      setup do
        # We do not want to skip Recaptcha in these tests
        Recaptcha::Verify.stubs(skip?: false)
        Model.spam_protection.enable_checks!(:javascript, :honeypot, :timestamp)
        @object = Model.new
        @object.stubs(:errors).returns({})
        @template = ActionView::Base.new
        @template.stubs(:logged_in?).returns(false)
        @output = @template.output_buffer = ActiveSupport::SafeBuffer.new
        @block = proc do |form|
          @template.safe_concat subject
        end
        @form = ThreeScale::SemanticFormBuilder.new(:model, @object, @template, {})
        subject.stubs(:enabled?).returns(true)
        http_method = Struct.new(:get?)
        subject.stubs(:http_method).returns(http_method.new(get?: false))
      end

      test "should not render captcha" do
        subject.stubs(:captcha_needed?).returns(false)
        @block.call(@form)
        assert_match /<li .+? id="model_confirmation_input" class="boolean required"/, @output
        assert_match /If you're human, leave this field empty./, @output
        assert_match /type="hidden" name="model\[timestamp\]"/, @output
        assert_match /noscript/, @output
      end

      test 'should not render captcha because of missing configuration' do
        subject.stubs(:level).returns(:captcha)
        subject.stubs(:captcha_configured?).returns(false)
        @block.call(@form)
        assert_match /<li .+? id="model_confirmation_input" class="boolean required"/, @output
        assert_match /If you're human, leave this field empty./, @output
        assert_match /type="hidden" name="model\[timestamp\]"/, @output
        assert_match /noscript/, @output
      end

      test 'should render captcha - configuration has been added' do
        subject.stubs(:level).returns(:captcha)
        subject.stubs(:captcha_configured?).returns(true)
        @block.call(@form)
        assert_match %r{src="https://www.google.com/recaptcha/api.js}, @output
        assert_match %r{src="https://www.google.com/recaptcha/api/fallback}, @output
        assert_match /name="g-recaptcha-response"/, @output
      end

      test "should render captcha" do
        subject.stubs(:captcha_needed?).returns(true)
        @block.call(@form)
        assert_match %r{src="https://www.google.com/recaptcha/api.js}, @output
        assert_match %r{src="https://www.google.com/recaptcha/api/fallback}, @output
        assert_match /name="g-recaptcha-response"/, @output
      end
    end
  end
end
