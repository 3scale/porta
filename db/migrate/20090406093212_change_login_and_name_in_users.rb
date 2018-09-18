class ChangeLoginAndNameInUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.remove :name
      t.string :first_name
      t.string :last_name
      t.rename :login, :username
      t.index :email
    end
  end

  def self.down
    change_table :users do |t|
      t.remove_index :column => :email
      t.remove :first_name
      t.remove :last_name
      t.string :name
      t.rename :username, :login
    end
  end
end
