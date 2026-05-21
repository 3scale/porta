# frozen_string_literal: true

require 'test_helper'

# Integration tests for ApiAuthentication::ByZyncToken.
#
# Uses a fake controller with fake routes (pattern from forbid_params_test.rb) to
# avoid coupling to real Admin API controllers and their additional before_actions.
module ApiAuthentication
  module ByZyncTokenIntegration
    # Minimal base that mirrors what real Admin API controllers set up:
    # ApplicationController -> ByAccessToken -> ByZyncToken.
    class FakeController < Admin::Api::BaseController
      include ApiAuthentication::ByZyncToken

      def show
        render json: { account_id: current_account.id, user_id: current_user.id }
      end

      def update
        render plain: 'ok'
      end
    end

    # Controller whose show action attempts a DB write — used to prove the
    # read-only transaction blocks it.
    class WriteAttemptController < FakeController
      def show
        User.where(id: -1).update_all(username: 'hacked')
        render plain: 'ok'
      rescue ActiveRecord::StatementInvalid => e
        render plain: e.message, status: :forbidden
      end
    end

    module TestHelpers
      ZYNC_TOKEN = 'test-zync-token'

      def with_test_routes
        Rails.application.routes.draw do
          get '/zync_test/show'          => 'api_authentication/by_zync_token_integration/fake#show'
          put '/zync_test/update'        => 'api_authentication/by_zync_token_integration/fake#update'
          get '/zync_test/write_attempt' => 'api_authentication/by_zync_token_integration/write_attempt#show'
        end
        yield
      ensure
        Rails.application.routes_reloader.reload!
      end

      def zync_headers(token = ZYNC_TOKEN)
        { 'X-Zync-Token' => token }
      end
    end
  end

  class ByZyncTokenIntegrationTest < ActionDispatch::IntegrationTest
    include ByZyncTokenIntegration::TestHelpers

    def setup
      ThreeScale.config.stubs(:zync_authentication_token).returns(ZYNC_TOKEN)
      @provider = FactoryBot.create(:provider_account)
      host! @provider.external_admin_domain
    end
  end

  class AccessTokenTest < ByZyncTokenIntegrationTest
    test 'rejects GET with no auth at all' do
      with_test_routes do
        get '/zync_test/show'
        assert_response :forbidden
      end
    end

    test 'regular access token auth still works on Zync-capable endpoints' do
      user  = FactoryBot.create(:member, account: @provider, admin_sections: %w[partners])
      token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management', permission: 'rw')
      with_test_routes do
        get '/zync_test/show', params: { access_token: token.plaintext_value }
        assert_response :success
      end
    end

    test 'oidc_sync tokens are rejected even on Zync-capable endpoints' do
      user  = FactoryBot.create(:member, account: @provider, admin_sections: %w[partners])
      token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management',
                                name: AccessToken::OIDC_SYNC_TOKEN)
      with_test_routes do
        get '/zync_test/show', params: { access_token: token.plaintext_value }
        assert_response :forbidden
      end
    end
  end

  class ZyncTokenTest < ByZyncTokenIntegrationTest
    disable_transactional_fixtures!

    test 'rejects GET with an invalid X-Zync-Token' do
      with_test_routes do
        get '/zync_test/show', headers: zync_headers('wrong')
        assert_response :forbidden
      end
    end

    test 'rejects requests targeting the master domain even with a valid X-Zync-Token' do
      host! master_account.internal_admin_domain
      with_test_routes do
        get '/zync_test/show', headers: zync_headers
        assert_response :forbidden
      end
    end

    test 'does not authenticate write actions via X-Zync-Token' do
      with_test_routes do
        put '/zync_test/update', headers: zync_headers
        assert_response :forbidden
      end
    end

    test 'authenticates GET requests with a valid X-Zync-Token' do
      with_test_routes do
        get '/zync_test/show', headers: zync_headers
        assert_response :success
      end
    end

    test 'Zync-authenticated requests enforce a read-only DB transaction' do
      with_test_routes do
        get '/zync_test/write_attempt', headers: zync_headers
        assert_response :forbidden
        assert_match(/read.only transaction/i, response.body)
      end
    end
  end

  class DomainRoutingTest < ByZyncTokenIntegrationTest
    disable_transactional_fixtures!

    test 'authenticates as the admin of the provider whose domain is in the Host header' do
      with_test_routes do
        get '/zync_test/show', headers: zync_headers
        assert_response :success
        assert_equal @provider.id, response.parsed_body['account_id']
      end
    end

    test 'X-Forwarded-Host overrides Host header for domain resolution' do
      provider_b = FactoryBot.create(:provider_account)
      with_test_routes do
        get '/zync_test/show', headers: zync_headers.merge('X-Forwarded-Host' => provider_b.internal_admin_domain)
        assert_response :success
        assert_equal provider_b.id, response.parsed_body['account_id']
      end
    end

    test 'rejects master domain via X-Forwarded-Host even with valid Zync token' do
      with_test_routes do
        get '/zync_test/show', headers: zync_headers.merge('X-Forwarded-Host' => master_account.internal_admin_domain)
        assert_response :forbidden
      end
    end
  end
end
