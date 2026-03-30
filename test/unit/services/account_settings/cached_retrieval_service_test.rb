# frozen_string_literal: true

require 'test_helper'

class AccountSettings::CachedRetrievalServiceTest < ActiveSupport::TestCase

  setup do
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    @provider = FactoryBot.create(:provider_account)
  end

  teardown do
    Rails.cache.clear
    Rails.cache = @original_cache
  end

  test 'returns setting value when it exists' do
    @provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderAdmin',
      value: 'camera=(), microphone=()'
    )

    result = AccountSettings::CachedRetrievalService.call(
      account: @provider, setting_name: :permissions_policy_header_admin
    )

    assert_equal 'camera=(), microphone=()', result.result
  end

  test 'returns default value when no setting exists' do
    result = AccountSettings::CachedRetrievalService.call(
      account: @provider, setting_name: :permissions_policy_header_admin
    )

    assert_equal AccountSetting::PermissionsPolicyHeaderAdmin.default_value, result.result
  end

  test 'caches the value after first call' do
    @provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper',
      value: 'camera=(), geolocation=()'
    )

    AccountSettings::CachedRetrievalService.call(
      account: @provider, setting_name: :permissions_policy_header_developer
    )

    cache_key = "account:#{@provider.id}:permissions_policy_header_developer"
    assert_equal 'camera=(), geolocation=()', Rails.cache.read(cache_key)
  end

  test 'writes provided value directly to cache' do
    AccountSettings::CachedRetrievalService.call(
      account: @provider, setting_name: :permissions_policy_header_admin, value: 'geolocation=()'
    )

    cache_key = "account:#{@provider.id}:permissions_policy_header_admin"
    assert_equal 'geolocation=()', Rails.cache.read(cache_key)
  end

  test 'writes nil value to cache when explicitly provided' do
    AccountSettings::CachedRetrievalService.call(
      account: @provider, setting_name: :permissions_policy_header_admin, value: nil
    )

    cache_key = "account:#{@provider.id}:permissions_policy_header_admin"
    assert_nil Rails.cache.read(cache_key)
    assert Rails.cache.exist?(cache_key)
  end
end
