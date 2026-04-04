# frozen_string_literal: true

require 'test_helper'

class PermissionsPolicyCacheTest < ActionDispatch::IntegrationTest

  setup do
    # Use memory store for cache tests instead of null store
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache.clear
    Rails.cache = @original_cache
  end

  test 'admin portal caches Permissions-Policy header value' do
    provider = FactoryBot.create(:provider_account)
    provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderAdmin',
      value: 'camera=(), microphone=()'
    )

    Provider::Admin::BaseController.any_instance.stubs(:site_account).returns(provider)

    login_provider provider

    # First request - should cache the value
    get edit_provider_admin_security_path
    assert_response :success
    assert_equal 'camera=(), microphone=()', response.headers['Permissions-Policy']

    # Verify cache was set
    cache_key = "account:#{provider.id}:permissions_policy_header_admin"
    assert_equal 'camera=(), microphone=()', Rails.cache.read(cache_key)
  end

  test 'developer portal caches Permissions-Policy header value' do
    provider = FactoryBot.create(:provider_account)
    buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    user = FactoryBot.create(:user, account: buyer)
    user.activate!

    provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper',
      value: 'camera=(), geolocation=()'
    )

    Sites::BaseController.any_instance.stubs(:site_account).returns(provider)

    login_provider provider

    # First request - should cache the value
    get edit_admin_site_security_path
    assert_response :success
    assert_equal 'camera=(), geolocation=()', response.headers['Permissions-Policy']

    # Verify cache was set
    cache_key = "account:#{provider.id}:permissions_policy_header_developer"
    assert_equal 'camera=(), geolocation=()', Rails.cache.read(cache_key)
  end
end
