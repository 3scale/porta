class AddSignupTypeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :signup_type, :string
  end

  def self.down
    remove_column :users, :signup_type
  end
end
