class BusinessCategoryFields < ActiveRecord::Migration
  def self.up
    add_column :accounts, :primary_business, :string
    add_column :accounts, :business_category, :string
    add_column :accounts, :zip, :string
  end

  def self.down
    remove_column :accounts, :primary_business
    remove_column :accounts, :business_category
    remove_column :accounts, :zip
  end
end
