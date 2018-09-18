class DeprecateSettingsBillingMode < ActiveRecord::Migration
  def self.up
    rename_column :settings, :billing_mode, :billing_mode_deprecated
  end

  def self.down
    rename_column :settings, :billing_mode_deprecated, :billing_mode
  end
end
