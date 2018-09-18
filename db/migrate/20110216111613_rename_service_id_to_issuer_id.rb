class RenameServiceIdToIssuerId < ActiveRecord::Migration
  def self.up
    add_column :plans, :issuer_type, :string, :null => false, :default => 'Service'
    rename_column :plans, :service_id, :issuer_id
    
    add_index :plans, :issuer_type
    add_index :plans, [:issuer_type, :issuer_id]
  end

  def self.down
    remove_column :plans, :issuer_type
    rename_column :plans, :issuer_id, :service_id
  end
end
