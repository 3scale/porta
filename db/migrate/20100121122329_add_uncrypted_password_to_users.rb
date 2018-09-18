class AddUncryptedPasswordToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :uncrypted_password, :string
  end

  def self.down
    remove_column :users, :uncrypted_password
  end
end
