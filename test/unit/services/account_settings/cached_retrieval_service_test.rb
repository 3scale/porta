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

  test 'serves subsequent calls from cache' do
    @provider.account_settings.create!(
      type: 'AccountSetting::PermissionsPolicyHeaderAdmin',
      value: 'camera=()'
    )

    # First call populates cache
    AccountSettings::CachedRetrievalService.call(
      account: @provider, setting_name: :permissions_policy_header_admin
    )

    # Change the DB value behind the cache
    @provider.account_settings.find_by(type: 'AccountSetting::PermissionsPolicyHeaderAdmin')
            .update!(value: 'microphone=()')

    # Second call should return cached (stale) value
    result = AccountSettings::CachedRetrievalService.call(
      account: @provider, setting_name: :permissions_policy_header_admin
    )

    assert_equal 'camera=()', result.result
  end
end
