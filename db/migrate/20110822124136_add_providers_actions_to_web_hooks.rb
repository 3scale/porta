class AddProvidersActionsToWebHooks < ActiveRecord::Migration
  def self.up
    add_column :web_hooks, :provider_actions, :boolean, :default => false
  end

  def self.down
    remove_column :web_hooks, :provider_actions
  end
end
