class AddAccountIdToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :account_id, :integer
    add_index  :categories, 'account_id'
  end

  def self.down
    remove_column :categories, :account_id
  end
end
