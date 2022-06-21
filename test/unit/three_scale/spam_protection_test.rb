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

  class EmptyModelTest < ActiveSupport::TestCase
    class Empty
      include ThreeScale::SpamProtection::Integration::Model
    end

    test "empty Model should have no spam protection" do
      assert_nil Empty.spam_protection
    end
  end

  class ModelsTest < ActiveSupport::TestCase
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

  class ControllersTest < ActiveSupport::TestCase
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

  class ModelIntegrationTest < ActiveSupport::TestCase
    class Model
      include ThreeScale::SpamProtection::Integration::Model
      has_spam_protection :honeypot, :timestamp
    end

    class ClassTest < ModelIntegrationTest
      test "should have right methods" do
        subject = Model
        assert subject.respond_to?(:spam_protection)
        assert_not subject.respond_to?(:spam_protection=)
      end
    end

    class ConfigurationTest < ModelIntegrationTest
      setup do
        @subject = Model.spam_protection
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
    end

    class InstanceTest < ModelIntegrationTest
      setup do
        @subject = Model.new
      end

      attr_reader :subject

      test "should have right methods" do
        method = subject.method(:spam_protection)
        assert method
        assert_equal 0, method.arity
      end

      test "should have spam level" do
        assert_equal 0.4, subject.spam_protection.spam_level
      end
    end

    class TimestampTest < ModelIntegrationTest
      test "validate" do
        subject = Timestamp.new
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

    class FormProtectionTest < ModelIntegrationTest
      class ModelJS < Model
        include ThreeScale::SpamProtection::Integration::Model
        has_spam_protection :honeypot, :timestamp, :javascript
      end

      setup do
        # We do not want to skip Recaptcha in these tests
        Recaptcha.configuration.skip_verify_env.delete('test')
        @object = ModelJS.new
        @object.stubs(:errors).returns({})
        @template = ActionView::Base.new
        @template.stubs(:logged_in?).returns(false)
        @output = @template.output_buffer = ActiveSupport::SafeBuffer.new
        @block = proc do |form|
          @template.safe_concat subject # rubocop:disable Rails/OutputSafety
        end
        @form = ThreeScale::SemanticFormBuilder.new(:model, @object, @template, {})
        @subject = @object.spam_protection.form(@form)
        subject.stubs(:enabled?).returns(true)
        http_method = Struct.new(:get?)
        subject.stubs(:http_method).returns(http_method.new(get?: false))
      end

      attr_reader :subject

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
        @block.call(@form)
        assert_match %r{src="https://www.recaptcha.net/recaptcha/api.js}, @output
        assert_match %r{src="https://www.recaptcha.net/recaptcha/api/fallback}, @output
        assert_match /name="g-recaptcha-response"/, @output
      end

      test "should render captcha" do
        subject.stubs(:captcha_needed?).returns(true)
        @block.call(@form)
        assert_match %r{src="https://www.recaptcha.net/recaptcha/api.js}, @output
        assert_match %r{src="https://www.recaptcha.net/recaptcha/api/fallback}, @output
        assert_match /name="g-recaptcha-response"/, @output
      end
    end
  end
end
