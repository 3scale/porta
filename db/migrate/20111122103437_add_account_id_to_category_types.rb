class AddAccountIdToCategoryTypes < ActiveRecord::Migration
  def self.up
    add_column :category_types, :account_id, :integer
    add_index  :category_types, 'account_id'
  end

  def self.down
    remove_column :category_types, :account_id
  end
end
