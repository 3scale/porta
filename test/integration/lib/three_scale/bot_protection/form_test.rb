# frozen_string_literal: true

require 'test_helper'

module ThreeScale
  module BotProtection
    class FormTest < ActionDispatch::IntegrationTest

      setup do
        Recaptcha.stubs(:captcha_configured?).returns(true)
      end

      class TestFormBuilder < ::Formtastic::FormBuilder
        include ThreeScale::BotProtection::Form

        delegate :controller, to: :template
      end

      class TestController < ApplicationController
        def new
          template = ActionView::Base.new(ActionView::LookupContext.new([]), {}, self)
          form = TestFormBuilder.new(:account, Account.new, template, {})
          render plain: form.bot_protection_inputs
        end
      end

      test 'shows reCaptcha when bot protection is enabled' do
        TestFormBuilder.any_instance.stubs(:bot_protection_level).returns(:captcha)

        with_test_routes do
          get '/test/new'

          assert_response :success
          assert_captcha
        end
      end

      test "doesn't show reCaptcha when bot protection is disabled" do
        TestFormBuilder.any_instance.stubs(:bot_protection_level).returns(:none)

        with_test_routes do
          get '/test/new'

          assert_response :success
          assert_no_captcha
        end
      end

      private

      def with_test_routes
        Rails.application.routes.draw do
          get '/test/new' => 'three_scale/bot_protection/form_test/test#new'
        end
        yield
      ensure
        Rails.application.routes_reloader.reload!
      end

      def assert_captcha
        assert_match /g-recaptcha g-recaptcha-response/, response.body
      end

      def assert_no_captcha
        assert_not_match /g-recaptcha g-recaptcha-response/, response.body
      end
    end
  end
end
