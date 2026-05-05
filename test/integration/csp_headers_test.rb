# frozen_string_literal: true

require 'test_helper'

class CspHeadersTest < ActionDispatch::IntegrationTest

  test 'admin portal sets Content-Security-Policy header from AccountSetting' do
    provider = FactoryBot.create(:provider_account)
    provider.account_settings.create!(
      type: 'CspHeaderAdmin',
      value: "default-src 'self'"
    )

    login_provider provider
    get edit_provider_admin_security_path

    assert_response :success
    assert_equal "default-src 'self'", response.headers['Content-Security-Policy']
  end

  test 'admin portal does not set header when setting is blank' do
    provider = FactoryBot.create(:provider_account)
    provider.account_settings.create!(
      type: 'CspHeaderAdmin',
      value: ''
    )

    login_provider provider
    get edit_provider_admin_security_path

    assert_response :success
    assert_nil response.headers['Content-Security-Policy']
  end

  test 'developer portal sets Content-Security-Policy header from AccountSetting' do
    provider = FactoryBot.create(:provider_account)
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    user = FactoryBot.create(:user, account: buyer)
    user.activate!

    provider.account_settings.create!(
      type: 'CspHeaderDeveloper',
      value: "default-src 'self'"
    )

    DeveloperPortal::BaseController.any_instance.stubs(:site_account).returns(provider)

    host! provider.internal_domain
    login_with user.username, 'superSecret1234#'
    get '/admin'

    assert_response :success
    assert_equal "default-src 'self'", response.headers['Content-Security-Policy']
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
    assert_nil response.headers['Content-Security-Policy']
  end

  test 'developer portal sets Content-Security-Policy header on unauthenticated pages' do
    provider = FactoryBot.create(:provider_account)
    provider.account_settings.create!(
      type: 'CspHeaderDeveloper',
      value: "default-src 'self'"
    )

    host! provider.internal_domain
    get '/login'

    assert_response :success
    assert_equal "default-src 'self'", response.headers['Content-Security-Policy']
  end

  test 'admin portal sets Content-Security-Policy-Report-Only header from AccountSetting' do
    provider = FactoryBot.create(:provider_account)
    provider.account_settings.create!(
      type: 'CspReportOnlyHeaderAdmin',
      value: "default-src 'none'"
    )

    login_provider provider
    get edit_provider_admin_security_path

    assert_response :success
    assert_equal "default-src 'none'", response.headers['Content-Security-Policy-Report-Only']
  end

  test 'admin portal sets both CSP headers simultaneously' do
    provider = FactoryBot.create(:provider_account)
    provider.account_settings.create!(
      type: 'CspHeaderAdmin',
      value: "default-src 'self'"
    )
    provider.account_settings.create!(
      type: 'CspReportOnlyHeaderAdmin',
      value: "default-src 'none'"
    )

    login_provider provider
    get edit_provider_admin_security_path

    assert_response :success
    assert_equal "default-src 'self'", response.headers['Content-Security-Policy']
    assert_equal "default-src 'none'", response.headers['Content-Security-Policy-Report-Only']
  end

  test 'developer portal sets Content-Security-Policy-Report-Only header from AccountSetting' do
    provider = FactoryBot.create(:provider_account)
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    user = FactoryBot.create(:user, account: buyer)
    user.activate!

    provider.account_settings.create!(
      type: 'CspReportOnlyHeaderDeveloper',
      value: "default-src 'none'"
    )

    DeveloperPortal::BaseController.any_instance.stubs(:site_account).returns(provider)

    host! provider.internal_domain
    login_with user.username, 'superSecret1234#'
    get '/admin'

    assert_response :success
    assert_equal "default-src 'none'", response.headers['Content-Security-Policy-Report-Only']
  end

  test 'developer portal sets both CSP headers simultaneously' do
    provider = FactoryBot.create(:provider_account)
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    user = FactoryBot.create(:user, account: buyer)
    user.activate!

    provider.account_settings.create!(
      type: 'CspHeaderDeveloper',
      value: "default-src 'self'"
    )
    provider.account_settings.create!(
      type: 'CspReportOnlyHeaderDeveloper',
      value: "default-src 'none'"
    )

    DeveloperPortal::BaseController.any_instance.stubs(:site_account).returns(provider)

    host! provider.internal_domain
    login_with user.username, 'superSecret1234#'
    get '/admin'

    assert_response :success
    assert_equal "default-src 'self'", response.headers['Content-Security-Policy']
    assert_equal "default-src 'none'", response.headers['Content-Security-Policy-Report-Only']
  end
end
