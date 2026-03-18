# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::WebhooksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @provider.settings.allow_web_hooks!
    login_provider @provider
  end

  test 'new when webhook does not exist' do
    get new_provider_admin_webhooks_path

    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:webhook)
    assert assigns(:webhook).new_record?
  end

  test 'new redirects to edit when webhook already exists' do
    FactoryBot.create(:web_hook, account: @provider)

    get new_provider_admin_webhooks_path

    assert_redirected_to edit_provider_admin_webhooks_path
  end

  test 'edit when webhook exists' do
    webhook = FactoryBot.create(:web_hook, account: @provider, url: 'http://example.com/hook')

    get edit_provider_admin_webhooks_path

    assert_response :success
    assert_template :edit
    assert_equal webhook, assigns(:webhook)
  end

  test 'edit redirects to new when webhook does not exist' do
    get edit_provider_admin_webhooks_path

    assert_redirected_to new_provider_admin_webhooks_path
  end

  test 'create webhook successfully' do
    assert_nil @provider.web_hook

    post provider_admin_webhooks_path, params: {
      web_hook: {
        url: 'http://example.com/webhook',
        active: true,
        account_created_on: true,
        application_created_on: true
      }
    }

    assert_redirected_to edit_provider_admin_webhooks_path
    assert_equal 'Webhooks settings were successfully updated', flash[:success]

    webhook = @provider.reload.web_hook
    assert_equal 'http://example.com/webhook', webhook.url
    assert webhook.active
    assert webhook.account_created_on
    assert webhook.application_created_on
  end

  test 'create webhook with invalid params shows errors' do
    assert_nil @provider.web_hook

    post provider_admin_webhooks_path, params: {
      web_hook: {
        url: '',  # invalid - blank URL
        active: true
      }
    }

    assert_nil @provider.reload.web_hook

    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:webhook)
    assert_equal ["Must be a valid URL such as http://example.com"], assigns(:webhook).errors[:url]
  end

  test 'update webhook successfully' do
    webhook = FactoryBot.create(:web_hook, account: @provider, url: 'http://old.com/hook', active: false)
    assert_not webhook.provider_actions

    put provider_admin_webhooks_path, params: {
      web_hook: {
        url: 'http://new.com/hook',
        active: true,
        provider_actions: true,
        user_created_on: true
      }
    }

    assert_redirected_to edit_provider_admin_webhooks_path
    assert_equal 'Webhooks settings were successfully updated', flash[:success]

    webhook.reload
    assert_equal 'http://new.com/hook', webhook.url
    assert webhook.active
    assert webhook.provider_actions
    assert webhook.user_created_on
  end

  test 'update webhook with invalid params shows errors' do
    webhook = FactoryBot.create(:web_hook, account: @provider, url: 'http://example.com/hook')

    put provider_admin_webhooks_path, params: {
      web_hook: {
        url: ''  # invalid
      }
    }

    assert_response :success
    assert_template :edit
    assert_equal 'Webhooks settings could not be updated', flash[:danger]

    webhook.reload
    assert_equal 'http://example.com/hook', webhook.url
  end

  test 'pings webhook and returns success' do
    FactoryBot.create(:web_hook, account: @provider, url: 'http://example.com/hook', active: true)

    # Mock successful ping
    ping_response = mock('ping_response')
    ping_response.stubs(:status).returns(200)
    ping_response.stubs(:respond_to?).with(:status).returns(true)
    WebHook.any_instance.stubs(:ping).returns(ping_response)

    get provider_admin_webhooks_path(format: :json)

    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 'success', json['type']
    assert_includes json['message'], 'http://example.com/hook'
    assert_includes json['message'], '200'
  end

  test 'show pings webhook and returns failure' do
    FactoryBot.create(:web_hook, account: @provider, url: 'http://example.com/hook')

    # Mock failed ping
    ping_response = mock('ping_response')
    ping_response.stubs(:message).returns('Connection refused')
    ping_response.stubs(:respond_to?).with(:status).returns(false)
    WebHook.any_instance.stubs(:ping).returns(ping_response)

    get provider_admin_webhooks_path(format: :json)

    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 'danger', json['type']
    assert_includes json['message'], 'Connection refused'
  end

  test 'show returns error when webhook does not exist' do
    get provider_admin_webhooks_path(format: :json)

    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 'danger', json['type']
    assert_equal 'Nowhere to ping', json['message']
  end

  test 'requires authorization to manage webhooks' do
    member = FactoryBot.create(:member, account: @provider, admin_sections: [:partners])
    member.activate!

    logout!
    login_provider @provider, user: member

    get new_provider_admin_webhooks_path

    assert_response :forbidden
  end

  test 'requires provider login' do
    logout!

    get new_provider_admin_webhooks_path

    assert_redirected_to provider_login_path
  end
end
