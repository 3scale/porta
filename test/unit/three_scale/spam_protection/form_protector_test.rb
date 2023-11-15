# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection
  class FormProtectionTest < ActiveSupport::TestCase
    class Controller < ApplicationController
      include ThreeScale::SpamProtection::Integration::Controller
      has_spam_protection :honeypot, :timestamp, :javascript
    end

    setup do
      # We do not want to skip Recaptcha in these tests
      Recaptcha::Verify.stubs(skip?: false)
      @object = FactoryBot.create(:account)
      @controller = Controller.new
      request = ActionDispatch::Request.new({})
      request.headers["REQUEST_METHOD"] = "POST"
      @controller.stubs(:request).returns(request)
      @controller.stubs(:site_account).returns(@object)
      @controller.instantiate_checks
      @template = ActionView::Base.new(ActionView::LookupContext.new([]), {}, @controller)
      @output = @template.output_buffer = ActiveSupport::SafeBuffer.new
      @block = proc do |form|
        @template.safe_concat subject # rubocop:disable Rails/OutputSafety
      end
      @form = Formtastic::FormBuilder.new(:model, @object, @template, {})
      @subject = @controller.spam_protection_form(@form)
    end

    attr_reader :subject

    class HttpMethodTest < FormProtectionTest
      test "#http_method returns the form HTTP method" do
        assert_equal "post", subject.http_method
      end
    end

    class LevelTest < FormProtectionTest
      test "#level returns the configured spam level" do
        @object.settings.spam_protection_level = :captcha
        @object.save!

        assert_equal :captcha, subject.level
      end

      test "#level returns :none when there's no configured spam level" do
        assert_equal :none, subject.level
      end
    end

    class CaptchaNeededTest < FormProtectionTest
      test "#captcha_needed? returns false when the spam level is :none" do
        subject.stubs(:level).returns(:none)

        assert_not subject.captcha_needed?
      end

      test "#captcha_needed? returns true when the spam level is :captcha" do
        subject.stubs(:level).returns(:captcha)

        assert subject.captcha_needed?
      end


      test "#captcha_needed? returns true when the client is marked as spam" do
        ThreeScale::SpamProtection::SessionStore.any_instance.stubs(:marked_as_possible_spam?).returns(true)

        assert subject.captcha_needed?
      end
    end

    class EnabledTest < FormProtectionTest
      test "#enabled? returns false when the spam level is :none" do
        subject.stubs(:level).returns(:none)

        assert_not subject.enabled?
      end


      test "#enabled? returns true when the spam level is not :none" do
        subject.stubs(:level).returns(:captcha)

        assert subject.enabled?
      end
    end

    class RenderTest < FormProtectionTest
      setup do
        subject.stubs(:enabled?).returns(true)
      end

      test "should not render captcha" do
        subject.stubs(:captcha_needed?).returns(false)
        @block.call(@form)
        assert_checks
      end

      test 'should not render captcha because of missing configuration' do
        subject.stubs(:level).returns(:captcha)
        Recaptcha.stubs(:captcha_configured?).returns(false)
        @block.call(@form)
        assert_checks
      end

      test 'should render captcha - configuration has been added' do
        subject.stubs(:level).returns(:captcha)
        subject.stubs(:captcha_configured?).returns(true)
        @block.call(@form)
        assert_captcha
      end

      test "should render captcha" do
        subject.stubs(:captcha_needed?).returns(true)
        @block.call(@form)
        assert_captcha
      end

      private

      def assert_checks
        html = Nokogiri::HTML4(@output)
        assert html.at_css('input[type="checkbox"][name="confirmation"]')
        assert html.at_css('input[type="text"][name="timestamp"]')
        assert html.at_css('noscript')
      end

      def assert_captcha
        assert_match %r{src="https://www.google.com/recaptcha/api.js}, @output
        assert_match %r{src="https://www.google.com/recaptcha/api/fallback}, @output
        assert_match /name="g-recaptcha-response"/, @output
      end
    end
  end
end
