# frozen_string_literal: true

require 'test_helper'

module ThreeScale
  module BotProtection
    class ControllerTest < ActionDispatch::IntegrationTest
      class TestController < ApplicationController
        include ThreeScale::BotProtection::Controller

        def create
          bot_check
          render plain: flash[:error] || 'Bot protection passed'
        end
      end

      setup do
        Recaptcha.stubs(:skip_env?).returns(false)
        Recaptcha.stubs(:invalid_response?).returns(false)
      end

      test "Doesn't detect a bot when the bot protection is disabled" do
        TestController.any_instance.stubs(:bot_protection_level).returns(:none)

        with_test_routes do
          post '/test/create'

          assert_response :success
          assert_equal 'Bot protection passed', response.body
        end
      end

      test "Doesn't detect a bot when the bot protection is enabled and the reCaptcha challenge passes" do
        TestController.any_instance.stubs(:bot_protection_level).returns(:captcha)
        Recaptcha.stubs(:verify_via_api_call).returns([true, {}])

        with_test_routes do
          post '/test/create'

          assert_response :success
          assert_equal 'Bot protection passed', response.body
        end
      end

      test "Detects a bot when the bot protection is enabled and the reCaptcha challenge fails" do
        TestController.any_instance.stubs(:bot_protection_level).returns(:captcha)
        Recaptcha.stubs(:verify_via_api_call).returns([false, {}])

        with_test_routes do
          post '/test/create'

          assert_response :success
          assert_equal 'reCAPTCHA verification failed, please try again.', response.body
        end
      end

      private

      def with_test_routes
        Rails.application.routes.draw do
          post '/test/create' => 'three_scale/bot_protection/controller_test/test#create'
        end
        yield
      ensure
        Rails.application.routes_reloader.reload!
      end
    end
  end
end
