# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest

  def setup
    @application_controller = ApplicationController.new
  end

  attr_reader :application_controller

  test 'check browser' do
    provider = FactoryBot.create(:provider_account)
    login! provider

    ApplicationController.any_instance.stubs(:browser_not_modern?).returns(false)
    get admin_buyers_accounts_path
    assert_response :success
    assert flash[:danger].blank?

    ApplicationController.any_instance.stubs(:browser_not_modern?).returns(true)
    get admin_buyers_accounts_path
    assert_response :redirect
    assert_match 'Please upgrade your browser and sign in again', flash[:warning]
  end

  test '#save_return_to' do
    assert_equal '/foo', application_controller.send(:safe_return_to, '/foo')
    assert_equal '/foo?bar=42', application_controller.send(:safe_return_to, '/foo?bar=42')
    assert_equal '/', application_controller.send(:safe_return_to, 'http://example.com/')
    assert_equal '/?foo=bar', application_controller.send(:safe_return_to, 'http://example.com/?foo=bar')
    assert_equal '/?foo=bar&foo2=bar2', application_controller.send(:safe_return_to, 'http://example.com/?foo=bar&foo2=bar2')
  end


  test 'tracks proxy config affecting changes' do
    provider = FactoryBot.create(:provider_account)
    login! provider

    ApplicationController.any_instance.expects(:track_proxy_affecting_changes)
    ApplicationController.any_instance.expects(:flush_proxy_affecting_changes)

    get admin_buyers_accounts_path
  end

  test "proxy config objects tracked for changes are cleared" do
    provider = FactoryBot.create(:provider_account)
    login! provider

    ProxyConfigAffectingChanges::Tracker.any_instance.expects(:reported_clear)
    # make sure #reported_clear is not called by #flush_proxy_affecting_changes
    ApplicationController.any_instance.expects(:flush_proxy_affecting_changes)

    get admin_buyers_accounts_path
  end

  test "forgery protection will force a 403 and revoke the session when no CSRF token provided" do
    provider = FactoryBot.create(:provider_account)
    user = provider.admins.first
    login! provider, user: user

    with_forgery_protection do
      post admin_buyers_accounts_path, params: {
        account: {
          org_name: 'Alaska',
          user: { email: 'foo@example.com', password: 'superSecret1234#', username: 'hello' }
        }
      }
    end
    assert_response :forbidden
    # Check that user session was revoked (because of token authenticity)
    assert_not_nil user.user_sessions.reload[0][:revoked_at]
  end

  test "forgery protection is skipped for API requests without authentication" do
    provider = FactoryBot.create(:provider_account)
    host! provider.external_admin_domain

    ApplicationController.any_instance.expects(:verify_authenticity_token).never

    with_forgery_protection do
      post admin_api_signup_path(format: :json), params: {
        org_name: 'Alaska', username: 'hello', email: 'foo@example.com', password: 'superSecret1234#'
      }
    end
    assert_response :forbidden
  end

  test "forgery protection is skipped for API requests with access token" do
    provider = FactoryBot.create(:provider_account)
    user = provider.admins.first
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management', permission: 'rw').value
    host! provider.external_admin_domain

    ApplicationController.any_instance.expects(:verify_authenticity_token).never

    with_forgery_protection do
      post admin_api_signup_path(format: :json), params: {
        access_token: token, org_name: 'Alaska',
        username: 'hello', email: 'foo@example.com', password: 'superSecret1234#'
      }
    end
    assert_response :created
  end

  test "forgery protection is skipped for API requests with basic auth and access token" do
    provider = FactoryBot.create(:provider_account)
    user = provider.admins.first
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management', permission: 'rw').value
    host! provider.external_admin_domain

    ApplicationController.any_instance.expects(:verify_authenticity_token).never

    with_forgery_protection do
      post admin_api_signup_path(format: :json), headers: {
        Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(token, '')
      }, params: {
        org_name: 'Alaska', username: 'hello', email: 'foo@example.com', password: 'superSecret1234#'
      }
    end
    assert_response :created
  end

  test "forgery protection is skipped for API requests with basic auth and provider key" do
    provider = FactoryBot.create(:provider_account)
    token = provider.api_key
    host! provider.external_admin_domain

    ApplicationController.any_instance.expects(:verify_authenticity_token).never

    with_forgery_protection do
      post admin_api_signup_path(format: :json), headers: {
        Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(token, '')
      }, params: {
        org_name: 'Alaska', username: 'hello', email: 'foo@example.com', password: 'superSecret1234#'
      }
    end
    assert_response :created
  end

  class ClientCaching < ActionDispatch::IntegrationTest
    def setup
      @provider = FactoryBot.create(:provider_account)
      @user = @provider.admins.first
      login! @provider, user: @user
    end

    class ClientCachingController < ApplicationController
      before_action :disable_client_cache

      def show; end
    end

    def with_test_routes
      Rails.application.routes.draw do
        get '/client_caching' => 'application_controller_test/client_caching/client_caching#show'
      end
      yield
    ensure
      Rails.application.routes_reloader.reload!
    end

    test "page should not cache" do
      with_test_routes do
        get '/client_caching'
      end

      assert_equal 'no-store', response.headers['Cache-Control']
      assert_equal 'no-cache', response.headers['Pragma']
      assert_equal 'Mon, 01 Jan 1990 00:00:00 GMT', response.headers['Expires']
    end
  end
end
