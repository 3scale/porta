class CreateValidators < ActiveRecord::Migration
  def self.up
    create_table :validators do |table|
      table.belongs_to :account
      table.string :model_class
      table.string :attribute
      table.boolean :required, :null => false, :default => false
    end

    add_index :validators, :account_id
  end

  def self.down
    remove_index :validators, :column => :account_id
    drop_table :validators
  end
end
