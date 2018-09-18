class MoveProductToSettings < ActiveRecord::Migration
  def self.up
    remove_column  :accounts, :product
    add_column :settings, :product, :string, :default => 'enterprise', :null => false
    change_column_default  :settings, :product, 'connect'
  end

  def self.down
    remove_column  :settings, :product
  end
end
