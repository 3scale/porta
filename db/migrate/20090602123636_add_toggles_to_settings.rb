class AddTogglesToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :billing_enabled, :boolean, :default => false

    add_column :settings, :forum_allowed,    :boolean, :default => true
    add_column :settings, :liquid_allowed,   :boolean, :default => false
    add_column :settings, :payments_allowed, :boolean, :default => false
    add_column :settings, :billing_allowed,  :boolean, :default => false
    
  end

  def self.down
    remove_column :settings, :billing_allowed
    remove_column :settings, :liquid_allowed
    remove_column :settings, :forum_allowed
    remove_column :settings, :payments_allowed
    remove_column :settings, :billing_enabled
  end
end
