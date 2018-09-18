class AddBackendV2ToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :backend_v2, :boolean, :default => true
  end

  def self.down
    remove_column :accounts, :backend_v2
  end
end
