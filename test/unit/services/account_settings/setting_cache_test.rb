# frozen_string_literal: true

require 'test_helper'

class AccountSettings::SettingCacheTest < ActiveSupport::TestCase

  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    @provider = FactoryBot.create(:provider_account)
  end

  teardown do
    Rails.cache.clear
    Rails.cache = @original_cache
  end

  test 'fetch returns setting value when it exists' do
    @provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderAdmin',
      value: 'camera=(), microphone=()'
    )

    result = AccountSettings::SettingCache.fetch(
      account: @provider, setting_name: :permissions_policy_header_admin
    )

    assert_equal 'camera=(), microphone=()', result
  end

  test 'fetch returns default value when no setting exists' do
    result = AccountSettings::SettingCache.fetch(
      account: @provider, setting_name: :permissions_policy_header_admin
    )

    assert_equal AccountSetting::PermissionsPolicyHeaderAdmin.default_value, result
  end

  test 'fetch caches the value after first call' do
    @provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper',
      value: 'camera=(), geolocation=()'
    )

    AccountSettings::SettingCache.fetch(
      account: @provider, setting_name: :permissions_policy_header_developer
    )

    cache_key = "account:#{@provider.id}:permissions_policy_header_developer"
    assert_equal 'camera=(), geolocation=()', Rails.cache.read(cache_key)
  end

  test 'set writes provided value directly to cache' do
    AccountSettings::SettingCache.set(
      account: @provider, setting_name: :permissions_policy_header_admin, value: 'geolocation=()'
    )

    cache_key = "account:#{@provider.id}:permissions_policy_header_admin"
    assert_equal 'geolocation=()', Rails.cache.read(cache_key)
  end

  test 'set writes nil value to cache when explicitly provided' do
    AccountSettings::SettingCache.set(
      account: @provider, setting_name: :permissions_policy_header_admin, value: nil
    )

    cache_key = "account:#{@provider.id}:permissions_policy_header_admin"
    assert_nil Rails.cache.read(cache_key)
    assert Rails.cache.exist?(cache_key)
  end
end
