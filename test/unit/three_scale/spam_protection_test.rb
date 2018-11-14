require 'test_helper'
#require 'three_scale/spam_protection'

class ThreeScale::SpamProtectionTest < ActiveSupport::TestCase
  class Model
    include ThreeScale::SpamProtection::Integration::Model
    has_spam_protection :honeypot, :timestamp
  end

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

  class Empty
    include ThreeScale::SpamProtection::Integration::Model
  end

  context "empty Model" do
    subject { Empty }
    should "have none spam protection" do
      assert subject.spam_protection.nil?
    end
  end

  context "SpamProtection::Integration" do
    context "Model" do
      subject { ThreeScale::SpamProtection::Integration::Model }
      should "not be included in ActiveRecord::Base" do
        assert !ActiveRecord::Base.ancestors.include?(subject)
      end

      should "be included in Account" do
        assert Account.ancestors.include?(subject)
      end

      should "be included in Post" do
        assert Account.ancestors.include?(subject)
      end

      should "be included in Topic" do
        assert Account.ancestors.include?(subject)
      end
    end

    context "Controller" do
      subject { ThreeScale::SpamProtection::Integration::Controller }

      should "not be included in ActionController::Base" do
        assert !ActionController::Base.ancestors.include?(subject)
      end

      should "be included in NewSignupsController" do
        assert DeveloperPortal::SignupController.ancestors.include?(subject)
      end
    end

    context "FormBuilder" do
      subject { ThreeScale::SpamProtection::Integration::FormBuilder }

      should "not be included in Formtastic::SemanticFormBuilder" do
        assert !Formtastic::SemanticFormBuilder.ancestors.include?(subject)
      end

      should "be included in ThreeScale::SemanticFormBuilder" do
        assert ThreeScale::SemanticFormBuilder.ancestors.include?(subject)
      end
    end
  end

  context "fake Model" do
    subject { Model }
    should "have right methods" do
      assert subject.respond_to?(:spam_protection)
      assert !subject.respond_to?(:spam_protection=)
    end

    context "configuration" do
      subject { Model.spam_protection }

      should "have have right allowed checks" do
        assert_equal [:honeypot, :timestamp], subject.enabled_checks
      end

      should "have #enabled? check" do
        assert subject.enabled?(:honeypot)
        assert subject.enabled?(:timestamp)
        assert !subject.enabled?(:javascript)
      end

    end

    context "instance" do
      subject { Model.new }
      should "have right methods" do
        method = subject.method(:spam_protection)
        assert method
        assert_equal 0, method.arity
      end

      should "have spam level" do
        assert_equal 0.4, subject.spam_protection.spam_level
      end
    end

    context "timestamp" do
      subject { Timestamp.new }

      should "validate" do
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

    context "form protector" do
      subject { @object.spam_protection.form(@form) }

      setup do
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

      should "not render captcha" do
        subject.stubs(:captcha_needed?).returns(false)
        @block.call(@form)
        assert_match %r{<li .+? id="model_confirmation_input" class="boolean required"}, @output
        assert_match %r{If you're human, leave this field empty.}, @output
        assert_match %r{type="hidden" name="model\[timestamp\]"}, @output
        assert_match %r{noscript}, @output
      end

      should 'not render captcha because of missing configuration' do
        subject.stubs(:level).returns(:captcha)
        subject.stubs(:captcha_configured?).returns(false)
        @block.call(@form)
        assert_match %r{<li .+? id="model_confirmation_input" class="boolean required"}, @output
        assert_match %r{If you're human, leave this field empty.}, @output
        assert_match %r{type="hidden" name="model\[timestamp\]"}, @output
        assert_match %r{noscript}, @output
      end

      should 'render captcha - configuration has been added' do 
        subject.stubs(:level).returns(:captcha)
        subject.stubs(:captcha_configured?).returns(true)
        @block.call(@form)
        assert_match %r{src="https://www.google.com/recaptcha/api.js}, @output
        assert_match %r{src="https://www.google.com/recaptcha/api/fallback}, @output
        assert_match %r{name="g-recaptcha-response\"}, @output
      end

      should "render captcha" do
        subject.stubs(:captcha_needed?).returns(true)
        @block.call(@form)
        assert_match %r{src="https://www.google.com/recaptcha/api.js}, @output
        assert_match %r{src="https://www.google.com/recaptcha/api/fallback}, @output
        assert_match %r{name="g-recaptcha-response\"}, @output
      end
    end
  end
end
