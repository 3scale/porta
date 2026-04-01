# frozen_string_literal: true

require 'test_helper'

class PermissionsPolicyHeadersTest < ActionDispatch::IntegrationTest

  test 'admin portal sets Permissions-Policy header from AccountSetting' do
    provider = FactoryBot.create(:provider_account)
    provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderAdmin',
      value: 'camera=(), microphone=()'
    )

    Provider::Admin::BaseController.any_instance.stubs(:site_account).returns(provider)

    login_provider provider
    get edit_provider_admin_bot_protection_path

    assert_response :success
    assert_equal 'camera=(), microphone=()', response.headers['Permissions-Policy']
  end

  test 'admin portal uses default Permissions-Policy when no setting exists' do
    provider = FactoryBot.create(:provider_account)

    Provider::Admin::BaseController.any_instance.stubs(:site_account).returns(provider)

    login_provider provider
    get edit_provider_admin_bot_protection_path

    assert_response :success
    assert_equal AccountSetting::PermissionsPolicyHeaderAdmin.default_value,
                 response.headers['Permissions-Policy']
  end

  test 'admin portal does not set header when setting is blank' do
    provider = FactoryBot.create(:provider_account)
    provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderAdmin',
      value: ''
    )

    Provider::Admin::BaseController.any_instance.stubs(:site_account).returns(provider)

    login_provider provider
    get edit_provider_admin_bot_protection_path

    assert_response :success
    assert_nil response.headers['Permissions-Policy']
  end

  test 'developer portal sets Permissions-Policy header from AccountSetting' do
    provider = FactoryBot.create(:provider_account)
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    user = FactoryBot.create(:user, account: buyer)
    user.activate!

    provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper',
      value: 'camera=(), geolocation=()'
    )

    DeveloperPortal::BaseController.any_instance.stubs(:site_account).returns(provider)

    host! provider.internal_domain
    login_with user.username, 'superSecret1234#'
    get '/admin'

    assert_response :success
    assert_equal 'camera=(), geolocation=()', response.headers['Permissions-Policy']
  end

  test 'developer portal does not set header when setting is blank (default)' do
    provider = FactoryBot.create(:provider_account)
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    user = FactoryBot.create(:user, account: buyer)
    user.activate!

    DeveloperPortal::BaseController.any_instance.stubs(:site_account).returns(provider)

    host! provider.internal_domain
    login_with user.username, 'superSecret1234#'
    get '/admin'

    assert_response :success
    assert_nil response.headers['Permissions-Policy']
  end

  test 'Sites controller (dev portal settings) sets Permissions-Policy header' do
    provider = FactoryBot.create(:provider_account)
    login_provider provider

    provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper',
      value: 'fullscreen=(self)'
    )

    Sites::SecuritiesController.any_instance.stubs(:site_account).returns(provider)

    get edit_admin_site_security_path

    assert_response :success
    assert_equal 'fullscreen=(self)', response.headers['Permissions-Policy']
  end
end
