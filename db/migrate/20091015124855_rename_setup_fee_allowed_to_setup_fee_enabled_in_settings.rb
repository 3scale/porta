class RenameSetupFeeAllowedToSetupFeeEnabledInSettings < ActiveRecord::Migration
  def self.up
    rename_column :settings, :setup_fee_allowed, :setup_fee_enabled
  end

  def self.down
    rename_column :settings, :setup_fee_enabled, :setup_fee_allowed
  end
end
