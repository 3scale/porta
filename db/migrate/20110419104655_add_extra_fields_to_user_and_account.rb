class AddExtraFieldsToUserAndAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :extra_fields, :text
    add_column :users, :extra_fields, :text
  end

  def self.down
    remove_column :accounts, :extra_fields
    remove_column :users, :extra_fields
  end
end
