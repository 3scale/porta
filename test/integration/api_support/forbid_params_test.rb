# frozen_string_literal: true

require 'test_helper'

class ApiSupport::ForbidParamsTest < ActionDispatch::IntegrationTest
  class TestController < ApplicationController
    include ApiSupport::ForbidParams
    def create
      params.permit(:permitted)
    end
  end

  def with_test_routes
    Rails.application.routes.draw do
      post '/test/default' => 'api_support/forbid_params_test/action/default/default#create'
      post '/test/log' => 'api_support/forbid_params_test/action/log/log#create'
      post '/test/reject' => 'api_support/forbid_params_test/action/reject/reject#create'
      post '/test/symbol' => 'api_support/forbid_params_test/whitelist/symbol/symbol#create'
      post '/test/string' => 'api_support/forbid_params_test/whitelist/string/string#create'
      post '/test/list' => 'api_support/forbid_params_test/whitelist/list/list#create'
      post '/test/child' => 'api_support/forbid_params_test/single_callback/child#create'
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

  class Action < ApiSupport::ForbidParamsTest
    class Default < Action
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

    class Log < Action
      class LogController < TestController
        forbid_extra_params :log
      end

      test 'writes on the log when forbid_extra_params = log' do
        with_test_routes do
          log_output = capture_log do
            post '/test/log', params: { unpermitted: true }
          end

          assert_response :success
          assert log_output.include?('Unpermitted parameters: ["unpermitted"]')
        end
      end
    end

    class Reject < Action
      class RejectController < TestController
        forbid_extra_params :reject
      end

      test 'returns 422 when forbid_extra_params = :reject' do
        with_test_routes do
          post '/test/reject', params: { unpermitted: true }

          assert_response :unprocessable_entity
        end
      end
    end
  end

  class Whitelist < ApiSupport::ForbidParamsTest
    class Symbol < Whitelist
      class SymbolController < TestController
        forbid_extra_params :reject, whitelist: :extra_permitted
      end

      test "returns 200 OK for a whitelisted parameter as symbol" do
        with_test_routes do
          post '/test/symbol', params: { extra_permitted: true }

          assert_response :success
        end
      end
    end

    class String < Whitelist
      class StringController < TestController
        forbid_extra_params :reject, whitelist: 'extra_permitted'
      end

      test "returns 200 OK for a whitelisted parameter as string" do
        with_test_routes do
          post '/test/string', params: { extra_permitted: true }

          assert_response :success
        end
      end
    end

    class List < Whitelist
      class ListController < TestController
        forbid_extra_params :reject, whitelist: %i[extra_permitted also_permitted]
      end

      test "returns 200 OK for a white list of parameters" do
        with_test_routes do
          post '/test/list', params: { also_permitted: true }

          assert_response :success
        end
      end
    end
  end

  class SingleCallback < ApiSupport::ForbidParamsTest
    class BaseController < TestController
      forbid_extra_params :log
    end

    class ChildController < BaseController
      forbid_extra_params :log
    end

    test 'the callback is only called once' do
      with_test_routes do
        ChildController.any_instance.expects(:_unpermitted_parameters_check).once
        post '/test/child', params: { unpermitted: true }
      end
    end
  end
end
