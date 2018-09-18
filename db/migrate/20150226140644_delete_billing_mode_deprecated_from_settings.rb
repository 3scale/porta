class DeleteBillingModeDeprecatedFromSettings < ActiveRecord::Migration
  def up
    remove_column :settings, :billing_mode_deprecated
  end

  def down
    add_column :settings, :billing_mode_deprecated, :string
  end
end
