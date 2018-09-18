class AddProductsDeliveredToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :products_delivered, :string
  end

  def self.down
    remove_column :profiles, :products_delivered
  end
end
