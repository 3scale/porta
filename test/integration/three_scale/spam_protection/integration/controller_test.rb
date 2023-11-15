# frozen_string_literal: true

require 'test_helper'

module ThreeScale::SpamProtection::Integration

  class ControllerTest < ActionDispatch::IntegrationTest

    def with_test_routes
      Rails.application.routes.draw do
        get '/test/index' => 'three_scale/spam_protection/integration/controller_test/test#index'
        get '/test/show' => 'three_scale/spam_protection/integration/controller_test/test#show'
        get '/test/new' => 'three_scale/spam_protection/integration/controller_test/test#new'
        post '/test/create' => 'three_scale/spam_protection/integration/controller_test/test#create'
      end
      yield
    ensure
      Rails.application.routes_reloader.reload!
    end

    class TestController < ApplicationController
      include ThreeScale::SpamProtection::Integration::Controller
      has_spam_protection :honeypot, :timestamp

      def index
        render plain: spam_protection_conf.enabled_checks
      end

      def show
        render plain: spam_protection_conf.enabled?(params[:check].to_sym)
      end

      def new
        Recaptcha::Verify.stubs(skip?: false)
        Recaptcha.stubs(:captcha_configured?).returns(true)
        template = ActionView::Base.new(ActionView::LookupContext.new([]), {}, self)
        form = Formtastic::FormBuilder.new(:model, Account.new, template, {})
        render plain: spam_protection_form(form).to_s
      end

      def create
        spam_check(Object.new)
      end
    end

    test "should instantiate tests" do
      with_test_routes do
        get '/test/index'

        assert_response :success
        assert_equal "[:honeypot, :timestamp]", response.body
      end
    end

    test ":javascript shouldn't be instantiated" do
      with_test_routes do
        get '/test/show', params: { check: :javascript}
        assert_response :success
        assert_equal "false", response.body
      end
    end

    test "should add the checks to the form when level is :auto" do
      TestController.any_instance.stubs(:level).returns(:auto)

      with_test_routes do
        get '/test/new'

        assert_response :success
        assert_checks
      end
    end

    test "should add the captcha to the form after a spam detection when level is :auto" do
      TestController.any_instance.stubs(:level).returns(:auto)
      ThreeScale::SpamProtection::Protector.any_instance.stubs(:spam?).returns(true)

      with_test_routes do
        post '/test/create'
        get '/test/new'

        assert_response :success
        assert_captcha
      end
    end

    test "should add the captcha to the form when level is :captcha" do
      TestController.any_instance.stubs(:level).returns(:captcha)

      with_test_routes do
        get '/test/new'

        assert_response :success
        assert_captcha
      end
    end

    test "should add nothing to the form when level is :none" do
      TestController.any_instance.stubs(:level).returns(:none)

      with_test_routes do
        get '/test/new'

        assert_response :success
        assert_no_protection
      end
    end

    private

    def assert_checks
      html = Nokogiri::HTML4(response.body)
      assert html.at_css('input[type="checkbox"][name="confirmation"]')
      assert html.at_css('input[type="text"][name="timestamp"]')
    end

    def assert_captcha
      assert_match %r{src="https://www.google.com/recaptcha/api.js}, response.body
      assert_match %r{src="https://www.google.com/recaptcha/api/fallback}, response.body
      assert_match /name="g-recaptcha-response"/, response.body
    end

    def assert_no_protection
      html = Nokogiri::HTML4(response.body)
      assert_not html.at_css('input[type="checkbox"][name="confirmation"]')
      assert_not_match %r{src="https://www.google.com/recaptcha/api.js}, response.body
    end
  end
end
