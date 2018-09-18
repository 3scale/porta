class AddProductToProvider < ActiveRecord::Migration
  def self.up
    add_column :accounts, :product, :string, :default => 'enterprise', :null => false
    change_column_default  :accounts, :product, 'connect'
  end

  def self.down
    remove_column  :accounts, :product
  end
end
