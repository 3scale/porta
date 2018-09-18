class AddIndicesToTags < ActiveRecord::Migration
  def self.up
    change_table :tags do |t|
      t.index :parent_id
      t.index :name, :unique => true
    end
  end

  def self.down
    change_table :tags do |t|
      t.remove_index :name
      t.remove_index :parent_id
    end
  end
end
