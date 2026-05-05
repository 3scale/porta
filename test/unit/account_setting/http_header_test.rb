# frozen_string_literal: true

require 'test_helper'

class AccountSetting::HttpHeaderTest < ActiveSupport::TestCase
  def setup
    @account = FactoryBot.build(:simple_provider)
    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  def teardown
    Rails.cache.clear
    Rails.cache = @original_cache
  end

  test 'accepts valid HTTP header values' do
    valid_value = "picture-in-picture=(), geolocation=(self https://example.com/), camera=*"

    setting = AccountSetting::PermissionsPolicyHeaderAdmin.new(
      account: @account,
      value: valid_value
    )

    assert setting.valid?, "Expected valid header to pass validation: #{setting.errors.full_messages}"
  end

  test 'rejects header values with newlines' do
    invalid_value = "camera 'none'\nInjected-Header: malicious"

    setting = AccountSetting::PermissionsPolicyHeaderAdmin.new(
      account: @account,
      value: invalid_value
    )

    assert_not setting.valid?
    assert_includes setting.errors[:value], "RFC 7230 allows only printable ASCII header values"
  end

  test 'rejects header values with carriage returns' do
    invalid_value = "camera 'none'\rmalicious"

    setting = AccountSetting::PermissionsPolicyHeaderAdmin.new(
      account: @account,
      value: invalid_value
    )

    assert_not setting.valid?
    assert_includes setting.errors[:value], "RFC 7230 allows only printable ASCII header values"
  end

  test 'accepts empty header values' do
    setting = AccountSetting::PermissionsPolicyHeaderAdmin.new(
      account: @account,
      value: ''
    )

    assert setting.valid?, "Expected empty header values to be valid: #{setting.errors.full_messages}"
  end

  test 'refreshes cache after create, update, and destroy' do
    account = FactoryBot.create(:simple_provider)
    service_args = { account: account, setting_name: 'permissions_policy_header_admin' }

    AccountSettings::SettingCache.expects(:set).with(**service_args, value: 'camera=()')
    setting = AccountSetting::PermissionsPolicyHeaderAdmin.create!(account: account, value: 'camera=()')

    AccountSettings::SettingCache.expects(:set).with(**service_args, value: 'microphone=()')
    setting.update!(value: 'microphone=()')

    AccountSettings::SettingCache.expects(:set).with(**service_args, value: AccountSetting::PermissionsPolicyHeaderAdmin.default_value)
    setting.destroy!
  end

  test 'display_name appends Header' do
    assert_equal 'Permissions-Policy Header', AccountSetting::PermissionsPolicyHeaderAdmin.display_name
    assert_equal 'Permissions-Policy Header', AccountSetting::PermissionsPolicyHeaderDeveloper.display_name
  end
end
