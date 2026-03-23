# frozen_string_literal: true

require 'test_helper'

class AccountSettingTest < ActiveSupport::TestCase
  test 'class_for_setting sanity check a few classes' do
    assert_equal AccountSetting::PermissionsPolicyHeaderAdmin, AccountSetting.class_for_setting(:permissions_policy_header_admin)
    assert_equal AccountSetting::PermissionsPolicyHeaderDeveloper, AccountSetting.class_for_setting(:permissions_policy_header_developer)
    assert_equal AccountSetting::PermissionsPolicyHeaderAdmin, AccountSetting.class_for_setting('permissions_policy_header_admin')
  end

  test 'class_for_setting returns nil for non-existent setting' do
    assert_nil AccountSetting.class_for_setting(:non_existent_setting)
  end

  test 'setting_name <-> class_for_setting roundtrip' do
    # Eager load all AccountSetting subclasses
    Rails.autoloaders.main.eager_load_dir(File.join(Rails.root, 'app', 'models', 'account_setting'))

    # Get all leaf classes (concrete implementations without further subclasses)
    leaf_classes = AccountSetting.descendants.select { |klass| klass.descendants.empty? }

    # Verify that converting to setting_name and back to class works for all leaf classes
    leaf_classes.each do |klass|
      setting_name = klass.setting_name
      assert_equal klass, AccountSetting.class_for_setting(setting_name),
                   "Failed roundtrip for #{klass.name}: setting_name=#{setting_name}"
    end
  end

  test 'tenant_id trigger' do
    account = FactoryBot.create(:simple_provider)
    setting = AccountSetting::PermissionsPolicyHeaderAdmin.create!(
      account: account,
      value: "camera 'none'; microphone 'self'"
    )
    assert setting.reload.tenant_id
    assert_equal account.id, setting.tenant_id
  end
end
