# frozen_string_literal: true

require 'test_helper'

class ApiSupport::ParamsTest < ActionDispatch::IntegrationTest

  class TestController < ApplicationController
    include ApiSupport::Params
    def create
      params.permit(:permitted)
    end
  end

  def with_test_routes
    Rails.application.routes.draw do
      post '/test/default' => 'api_support/params_test/class_action_on_unpermitted/default/default#create'
      post '/test/log' => 'api_support/params_test/class_action_on_unpermitted/log/log#create'
      post '/test/raise' => 'api_support/params_test/class_action_on_unpermitted/raise/raise#create'
      post '/test/permitted_param' => 'api_support/params_test/permitted_param/permitted_param#create'
    end
    yield
  ensure
    Rails.application.routes_reloader.reload!
  end

  def capture_log
    orig_logger = Rails.logger.dup
    logger_output = StringIO.new

    begin
      Rails.logger = ActiveSupport::Logger.new(logger_output)
      yield
    ensure
      Rails.logger = orig_logger
    end

    logger_output.string
  end

  class ClassActionOnUnpermitted < ApiSupport::ParamsTest
    class Default <ClassActionOnUnpermitted
      class DefaultController < TestController; end

      def setup
        ActionController::Parameters.action_on_unpermitted_parameters = :raise
      end

      def teardown
        ActionController::Parameters.action_on_unpermitted_parameters = false
      end

      test 'defaults to global action_on_unpermitted_parameters' do
        with_test_routes do
          assert_raises(ActionController::UnpermittedParameters) { post '/test/default', params: { unpermitted: true } }
        end
      end
    end

    class Log <ClassActionOnUnpermitted
      class LogController < TestController
        controller_action_on_unpermitted_parameters :log
      end

      test 'writes on the log when controller_action_on_unpermitted_parameters = log' do
        with_test_routes do
          log_output = capture_log do
            post '/test/log', params: { unpermitted: true }
          end

          assert log_output.include?('Unpermitted parameters: ["unpermitted"]')
        end
      end
    end

    class Raise <ClassActionOnUnpermitted
      class RaiseController < TestController
        controller_action_on_unpermitted_parameters :raise
      end

      test 'raises an ActionController::UnpermittedParameters when controller_action_on_unpermitted_parameters = :raise' do
        with_test_routes do
          assert_raises(ActionController::UnpermittedParameters) { post '/test/raise', params: { unpermitted: true } }
        end
      end
    end
  end

  class PermittedParam < ApiSupport::ParamsTest
    class PermittedParamController < TestController
      controller_action_on_unpermitted_parameters :raise
      controller_always_permitted_parameters :extra_permitted
    end

    test "doesn't raise an error for an always permitted parameter" do
      with_test_routes do
        post '/test/permitted_param', params: { extra_permitted: true }

        assert true # No error was raised
      end
    end
  end
end
