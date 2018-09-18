class RemoveMaxAppsFromAccount < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :max_apps
  end

  def self.down
    add_column :accounts, :max_apps, :integer, :default => 10
  end
end
