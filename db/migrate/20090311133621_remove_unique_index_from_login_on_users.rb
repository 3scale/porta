class RemoveUniqueIndexFromLoginOnUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.remove_index :column => :login
      t.index :login # Add it back, but non-unique
    end
  end

  def self.down
    change_table :users do |t|
      t.remove_index :column => :login
      t.index :login, :unique => true
    end
  end
end
