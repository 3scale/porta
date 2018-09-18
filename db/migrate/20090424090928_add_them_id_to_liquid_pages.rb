class AddThemIdToLiquidPages < ActiveRecord::Migration
  def self.up
    add_column :liquid_pages, :theme_id, :integer
  end

  def self.down
    remove_column :liquid_pages, :theme_id
  end
end
