class RemoveObsoleteConfigurationFieldsFromSettings < ActiveRecord::Migration
  def self.up
    change_table :settings do |table|
      table.remove :app_gallery_allowed
      table.remove :billing_allowed
      table.remove :billing_enabled
      table.remove :custom_plans_enabled
      table.remove :forum_allowed
      table.remove :liquid_enabled
      table.remove :method_tracking_enabled
    end
  end

  def self.down
    change_table :settings do |table|
      table.boolean :app_gallery_allowed
      table.boolean :billing_allowed
      table.boolean :billing_enabled
      table.boolean :custom_plans_enabled
      table.boolean :forum_allowed, :default => true
      table.boolean :liquid_enabled
      table.boolean :method_tracking_enabled
    end
  end
end
