# frozen_string_literal: true

require 'test_helper'

module RequestForgeryProtection
  class ExceptionAndResetStrategyTest < ActionDispatch::IntegrationTest
    def with_test_routes
      Rails.application.routes.draw do
        post '/signed' => 'request_forgery_protection/exception_and_reset_strategy_test/signed/signed#create'
        post '/unsigned' => 'request_forgery_protection/exception_and_reset_strategy_test/unsigned/unsigned#create'
      end
      yield
    ensure
      Rails.application.routes_reloader.reload!
    end

    class BaseProtectedController < ActionController::Base
      protect_from_forgery with: ActionController::RequestForgeryProtection::ExceptionAndResetStrategy

      def create; end
    end

    class Signed < ExceptionAndResetStrategyTest

      setup do
        @provider = FactoryBot.create(:provider_account)
        @user = @provider.admins.first
        login! @provider, user: @user
        SignedController.any_instance.stubs(:current_user).returns(@user)
      end

      class SignedController < BaseProtectedController
        include AuthenticatedSystem
        before_action :login_required
      end

      test 'should allow access when including a valid CSRF token' do
        SignedController.any_instance.stubs(:verified_request?).returns(true)

        with_forgery_protection do
          with_test_routes do
            post '/signed', params: { authenticity_token: 'valid' }
          end
        end

        assert_response :success
      end

      test 'should raise InvalidAuthenticityToken error when including an invalid CSRF token' do
        with_forgery_protection do
          with_test_routes do
            assert_raise ActionController::InvalidAuthenticityToken do
              post '/signed', params: { authenticity_token: 'invalid' }
            end
          end
        end
      end

      test 'should reset session when including an invalid a CSRF token' do
        with_forgery_protection do
          with_test_routes do
            suppress ActionController::InvalidAuthenticityToken do
              post '/signed', params: { authenticity_token: 'invalid' }
            end
          end
        end
        assert_not_nil @user.user_sessions.reload[0][:revoked_at]
      end
    end

    class Unsigned < ExceptionAndResetStrategyTest
      class UnsignedController < BaseProtectedController; end

      test 'should allow access when including a valid CSRF token' do
        UnsignedController.any_instance.stubs(:verified_request?).returns(true)

        with_forgery_protection do
          with_test_routes do
            post '/unsigned', params: { authenticity_token: 'valid' }
          end
        end

        assert_response :success
      end

      test 'should raise InvalidAuthenticityToken error when including an invalid CSRF token' do
        with_forgery_protection do
          with_test_routes do
            assert_raise ActionController::InvalidAuthenticityToken do
              post '/unsigned', params: { authenticity_token: 'invalid' }
            end
          end
        end
      end
    end
  end
end
