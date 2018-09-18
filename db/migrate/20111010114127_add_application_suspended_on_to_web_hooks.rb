class AddApplicationSuspendedOnToWebHooks < ActiveRecord::Migration
  def self.up
    add_column :web_hooks, :application_suspended_on, :boolean, :default => false
  end

  def self.down
    remove_column :web_hooks, :application_suspended_on
  end
end
