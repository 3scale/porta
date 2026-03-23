# frozen_string_literal: true

require 'test_helper'

class AccountSetting::HttpHeadersTest < ActiveSupport::TestCase
  def setup
    @account = FactoryBot.build(:simple_provider)
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
end
