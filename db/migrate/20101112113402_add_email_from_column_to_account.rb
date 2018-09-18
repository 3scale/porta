class AddEmailFromColumnToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :from_email, :string
  end

  def self.down
    remove_column :accounts, :from_email
  end
end
