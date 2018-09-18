class AddIndexServicesAccount < ActiveRecord::Migration
  def self.up
    add_index :services, 'account_id', :name => 'idx_account_id'
  end

  def self.down
    remove_index :services, :name => 'idx_account_id'
  end
end
