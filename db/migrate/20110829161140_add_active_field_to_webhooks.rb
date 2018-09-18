class AddActiveFieldToWebhooks < ActiveRecord::Migration
  def self.up
    add_column :web_hooks, :active, :boolean, :default => true
  end

  def self.down
    remove_column :web_hooks, :active
  end
end
