class AddTitleToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :title, :string
  end

  def self.down
    remove_column :users, :title
  end
end
